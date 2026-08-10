// niri IPC client — replaces AstalHyprland.
// niri speaks newline-delimited JSON over $NIRI_SOCKET. The "EventStream"
// request dumps full state up front and then streams deltas, so a single
// connection is enough to keep everything below in sync.
import Gio from "gi://Gio";
import GLib from "gi://GLib";
import { Variable } from "astal";

export type NiriWorkspace = {
  id: number;
  idx: number;
  name: string | null;
  output: string | null;
  is_active: boolean;
  is_focused: boolean;
  is_urgent: boolean;
  active_window_id: number | null;
};

export type NiriWindow = {
  id: number;
  title: string | null;
  app_id: string | null;
  workspace_id: number | null;
  is_focused: boolean;
  is_urgent?: boolean;
};

const RECONNECT_MS = 1000;

export const workspaces = Variable<NiriWorkspace[]>([]);
export const focusedWorkspace = Variable<NiriWorkspace | null>(null);
export const focusedOutput = Variable<string | null>(null);
export const focusedWindow = Variable<NiriWindow | null>(null);
export const overviewOpen = Variable(false);
export const keyboardLayout = Variable("");

const windows = new Map<number, NiriWindow>();
let focusedWindowId: number | null = null;
let started = false;

function publishWorkspaces(list: NiriWorkspace[]) {
  workspaces.set(list);

  const focused = list.find((ws) => ws.is_focused) ?? null;
  focusedWorkspace.set(focused);
  if (focused?.output) focusedOutput.set(focused.output);
}

function publishFocusedWindow() {
  focusedWindow.set(
    focusedWindowId === null ? null : (windows.get(focusedWindowId) ?? null),
  );
}

function handleEvent(event: Record<string, any>) {
  const [kind, data] = Object.entries(event)[0] ?? [];

  switch (kind) {
    case "WorkspacesChanged":
      publishWorkspaces(data.workspaces);
      break;

    // Workspace became active on its output; focused=true also moves output focus
    case "WorkspaceActivated": {
      const list = workspaces.get();
      const target = list.find((ws) => ws.id === data.id);
      if (!target) break;

      publishWorkspaces(
        list.map((ws) => ({
          ...ws,
          is_active:
            ws.output === target.output ? ws.id === target.id : ws.is_active,
          is_focused: data.focused ? ws.id === target.id : ws.is_focused,
        })),
      );
      break;
    }

    case "WorkspaceActiveWindowChanged":
      publishWorkspaces(
        workspaces.get().map((ws) =>
          ws.id === data.workspace_id
            ? {...ws, active_window_id: data.active_window_id}
            : ws,
        ),
      );
      break;

    case "WorkspaceUrgencyChanged":
      publishWorkspaces(
        workspaces
          .get()
          .map((ws) => (ws.id === data.id ? {...ws, is_urgent: data.urgent} : ws)),
      );
      break;

    case "WindowsChanged": {
      windows.clear();
      focusedWindowId = null;
      for (const win of data.windows as NiriWindow[]) {
        windows.set(win.id, win);
        if (win.is_focused) focusedWindowId = win.id;
      }
      publishFocusedWindow();
      break;
    }

    // Also fires on title changes — this is what keeps TitleComponent live
    case "WindowOpenedOrChanged": {
      const win = data.window as NiriWindow;
      windows.set(win.id, win);
      if (win.is_focused) focusedWindowId = win.id;
      if (focusedWindowId === win.id) publishFocusedWindow();
      break;
    }

    case "WindowClosed":
      windows.delete(data.id);
      if (focusedWindowId === data.id) {
        focusedWindowId = null;
        publishFocusedWindow();
      }
      break;

    case "WindowFocusChanged":
      focusedWindowId = data.id ?? null;
      publishFocusedWindow();
      break;

    case "WindowUrgencyChanged": {
      const win = windows.get(data.id);
      if (win) windows.set(data.id, {...win, is_urgent: data.urgent});
      break;
    }

    case "KeyboardLayoutsChanged":
      keyboardLayout.set(
        data.keyboard_layouts.names[data.keyboard_layouts.current_idx] ?? "",
      );
      break;

    case "KeyboardLayoutSwitched":
      // Names arrive with KeyboardLayoutsChanged; only the index moves here
      break;

    case "OverviewOpenedOrClosed":
      overviewOpen.set(data.is_open);
      break;
  }
}

function handleLine(line: string) {
  let payload: any;
  try {
    payload = JSON.parse(line);
  } catch (e) {
    console.error("niri: unparseable IPC line", line);
    return;
  }

  // First line is the request ack ({"Ok":"Handled"}), everything after is events
  if (payload && typeof payload === "object" && !("Ok" in payload) && !("Err" in payload))
    handleEvent(payload);
  else if (payload?.Err) console.error("niri: IPC error", payload.Err);
}

function reconnect(connection: Gio.SocketConnection) {
  try {
    connection.close(null);
  } catch (e) {
    // already dead
  }
  started = false;
  setTimeout(connect, RECONNECT_MS);
}

function readLines(stream: Gio.DataInputStream, connection: Gio.SocketConnection) {
  stream.read_line_async(GLib.PRIORITY_DEFAULT, null, (_source, result) => {
    let line: string | null = null;
    try {
      [line] = stream.read_line_finish_utf8(result);
    } catch (e) {
      console.error("niri: event stream read failed", e);
      reconnect(connection);
      return;
    }

    if (line === null) {
      // EOF — compositor restarted or socket dropped
      reconnect(connection);
      return;
    }

    if (line.length > 0) handleLine(line);
    readLines(stream, connection);
  });
}

export function connect() {
  if (started) return;

  const socketPath = GLib.getenv("NIRI_SOCKET");
  if (!socketPath) {
    console.error("niri: NIRI_SOCKET unset — window/workspace state unavailable");
    return;
  }

  let connection: Gio.SocketConnection;
  try {
    connection = new Gio.SocketClient().connect(
      Gio.UnixSocketAddress.new(socketPath),
      null,
    );
  } catch (e) {
    console.error("niri: cannot reach IPC socket, retrying", e);
    setTimeout(connect, RECONNECT_MS);
    return;
  }

  started = true;

  const out = new Gio.DataOutputStream({
    base_stream: connection.get_output_stream(),
  });
  out.put_string('"EventStream"\n', null);
  out.flush(null);

  readLines(
    new Gio.DataInputStream({base_stream: connection.get_input_stream()}),
    connection,
  );
}

// One-shot action on its own connection, e.g.
// niriAction({FocusWorkspace: {reference: {Id: 3}}})
export function niriAction(action: Record<string, any>) {
  const socketPath = GLib.getenv("NIRI_SOCKET");
  if (!socketPath) return;

  try {
    const connection = new Gio.SocketClient().connect(
      Gio.UnixSocketAddress.new(socketPath),
      null,
    );
    const out = new Gio.DataOutputStream({
      base_stream: connection.get_output_stream(),
    });
    out.put_string(`${JSON.stringify({Action: action})}\n`, null);
    out.flush(null);

    // Wait for the ack — closing early drops the request
    new Gio.DataInputStream({
      base_stream: connection.get_input_stream(),
    }).read_line_utf8(null);
    connection.close(null);
  } catch (e) {
    console.error("niri: action failed", e);
  }
}
