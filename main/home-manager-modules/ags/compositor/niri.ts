// niri backend. niri speaks newline-delimited JSON over $NIRI_SOCKET. The
// "EventStream" request dumps full state up front and then streams deltas, so
// a single connection is enough to keep the shared state in sync.
import Gdk from "gi://Gdk?version=3.0";
import Gio from "gi://Gio";
import GLib from "gi://GLib";
import { readFile } from "ags/file";
import { getMonitorPlugName } from "../util";
import {
  type Keybind,
  publishFillingOutputs,
  publishOccupiedOutputs,
  publishWorkspaces as publishShared,
  setScreencasting,
  setFocusedWindow,
  setKeyboardLayout,
  setMode,
  type Workspace,
} from "./state";

type NiriWorkspace = Workspace & {
  active_window_id: number | null;
};

type NiriWindow = {
  id: number;
  title: string | null;
  app_id: string | null;
  workspace_id: number | null;
  is_focused: boolean;
  is_urgent?: boolean;
  layout?: {tile_size: [number, number]};
};

const RECONNECT_MS = 1000;

let workspaces: NiriWorkspace[] = [];
const windows = new Map<number, NiriWindow>();
let focusedWindowId: number | null = null;
// Screencast stream id -> currently streaming frames
const casts = new Map<number, boolean>();
let started = false;

// Logical monitor widths, the same units as niri's tile sizes
function outputWidths() {
  const widths = new Map<string, number>();
  const display = Gdk.Display.get_default();
  for (let i = 0; i < (display?.get_n_monitors() ?? 0); i++) {
    const monitor = display!.get_monitor(i)!;
    const name = getMonitorPlugName(monitor);
    if (name) widths.set(name, monitor.get_geometry().width);
  }
  return widths;
}

// niri reports no maximized/fullscreen flag; a tile as wide as the output
// means maximize-to-edges or fullscreen (a full-width column keeps its gaps)
function publishFilling() {
  publishOccupiedOutputs(
    workspaces
      .filter((ws) => ws.is_active && ws.output && ws.active_window_id !== null)
      .map((ws) => ws.output!),
  );

  const widths = outputWidths();
  publishFillingOutputs(
    workspaces
      .filter((ws) => {
        if (!ws.is_active || !ws.output || ws.active_window_id === null)
          return false;
        const tile = windows.get(ws.active_window_id)?.layout?.tile_size;
        const width = widths.get(ws.output);
        return !!tile && !!width && tile[0] >= width - 2;
      })
      .map((ws) => ws.output!),
  );
}

function publishCasts() {
  setScreencasting([...casts.values()].some(Boolean));
}

function publishWorkspaces(list: NiriWorkspace[]) {
  workspaces = list;
  publishShared(list);
  publishFilling();
}

function publishFocusedWindow() {
  setFocusedWindow(
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
      const list = workspaces;
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
        workspaces.map((ws) =>
          ws.id === data.workspace_id
            ? {...ws, active_window_id: data.active_window_id}
            : ws,
        ),
      );
      break;

    case "WorkspaceUrgencyChanged":
      publishWorkspaces(
        workspaces.map((ws) =>
          ws.id === data.id ? {...ws, is_urgent: data.urgent} : ws,
        ),
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
      publishFilling();
      break;
    }

    // Also fires on title changes — this is what keeps TitleComponent live
    case "WindowOpenedOrChanged": {
      const win = data.window as NiriWindow;
      windows.set(win.id, win);
      if (win.is_focused) focusedWindowId = win.id;
      if (focusedWindowId === win.id) publishFocusedWindow();
      publishFilling();
      break;
    }

    case "WindowClosed":
      windows.delete(data.id);
      if (focusedWindowId === data.id) {
        focusedWindowId = null;
        publishFocusedWindow();
      }
      publishFilling();
      break;

    case "WindowLayoutsChanged":
      for (const [id, layout] of data.changes as [
        number,
        NiriWindow["layout"],
      ][]) {
        const win = windows.get(id);
        if (win) windows.set(id, {...win, layout});
      }
      publishFilling();
      break;

    case "CastsChanged":
      casts.clear();
      for (const cast of data.casts) casts.set(cast.stream_id, cast.is_active);
      publishCasts();
      break;

    case "CastStartedOrChanged":
      casts.set(data.cast.stream_id, data.cast.is_active);
      publishCasts();
      break;

    case "CastStopped":
      casts.delete(data.stream_id);
      publishCasts();
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
      setKeyboardLayout(
        data.keyboard_layouts.names[data.keyboard_layouts.current_idx] ?? "",
      );
      break;

    case "KeyboardLayoutSwitched":
      // Names arrive with KeyboardLayoutsChanged; only the index moves here
      break;

    case "OverviewOpenedOrClosed":
      setMode(data.is_open ? "OVERVIEW" : "NORMAL");
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
function niriAction(action: Record<string, any>) {
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

    // Wait for the ack — closing early drops the request. Async so a stuck
    // compositor can't freeze the shell.
    const input = new Gio.DataInputStream({
      base_stream: connection.get_input_stream(),
    });
    input.read_line_async(GLib.PRIORITY_DEFAULT, null, (_source, result) => {
      try {
        input.read_line_finish_utf8(result);
      } catch (e) {
        console.error("niri: action ack failed", e);
      }
      connection.close(null);
    });
  } catch (e) {
    console.error("niri: action failed", e);
  }
}

export function focusWorkspace(id: number) {
  niriAction({FocusWorkspace: {reference: {Id: id}}});
}

// niri has no submaps and doesn't expose binds over IPC, so read config.kdl
const CONFIG_PATH = `${GLib.get_user_config_dir()}/niri/config.kdl`;

// Matches `Mod+Shift+H hotkey-overlay-title="..." { swap-window-left; }`
const BIND_RE = /^([A-Za-z0-9_+]+)\s+(.*?)\{\s*(.*?)\s*\}$/;
const TITLE_RE = /hotkey-overlay-title="([^"]*)"/;

function describe(props: string, action: string) {
  const title = props.match(TITLE_RE)?.[1];
  if (title) return title.toUpperCase();

  // Unhyphenate the action name only — arguments like "-30" keep their sign
  const [verb, ...args] = action.replace(/;\s*$/, "").split(/\s+/);

  return [verb.replace(/-/g, " "), ...args.map((a) => a.replace(/"/g, ""))]
    .join(" ")
    .trim()
    .toUpperCase();
}

function parseKeybinds(kdl: string): Keybind[] {
  const binds: Keybind[] = [];
  let depth = 0;

  for (const raw of kdl.split("\n")) {
    const line = raw.replace(/\/\/.*$/, "").trim();
    if (!line) continue;

    if (depth === 0) {
      if (/^binds\s*\{/.test(line)) depth = 1;
      continue;
    }

    const match = line.match(BIND_RE);
    if (match) {
      binds.push({key: match[1], description: describe(match[2], match[3])});
      continue;
    }

    depth += (line.match(/\{/g)?.length ?? 0) - (line.match(/\}/g)?.length ?? 0);
    if (depth <= 0) break;
  }

  return binds;
}

export function loadKeybinds(): Keybind[] {
  try {
    return parseKeybinds(readFile(CONFIG_PATH));
  } catch (e) {
    console.error("niri: cannot read config.kdl for keybinds", e);
    return [];
  }
}
