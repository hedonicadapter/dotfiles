// Hyprland backend via AstalHyprland. AstalHyprland emits `event` after it
// has synced its own objects, so every event republishes from its state.
import AstalHyprland from "gi://AstalHyprland";
import {
  type Keybind,
  publishWorkspaces,
  setFocusedOutput,
  setFocusedWindow,
  setKeyboardLayout,
  setMode,
  type Window,
  type Workspace,
} from "./state";

let hypr: AstalHyprland.Hyprland | null = null;
let lastWorkspaces = "";
let lastWindow = "";

function publish() {
  if (!hypr) return;

  const focusedId = hypr.focusedWorkspace?.id;
  // Negative ids are special workspaces (scratchpads)
  const list: Workspace[] = hypr.workspaces
    .filter((ws) => ws.id > 0)
    .sort((a, b) => a.id - b.id)
    .map((ws) => ({
      id: ws.id,
      idx: 0,
      name: ws.name,
      output: ws.monitor?.name ?? null,
      is_active: ws.monitor?.activeWorkspace?.id === ws.id,
      is_focused: ws.id === focusedId,
      is_urgent: false,
    }));

  // hyprsplit gives each monitor its own id range; idx is the position on it
  const seen = new Map<string | null, number>();
  for (const ws of list) {
    ws.idx = (seen.get(ws.output) ?? 0) + 1;
    seen.set(ws.output, ws.idx);
  }

  // Every event lands here — skip unchanged state so widgets don't rebuild
  const wsKey = JSON.stringify(list);
  if (wsKey !== lastWorkspaces) {
    lastWorkspaces = wsKey;
    publishWorkspaces(list);
  }

  const output = hypr.focusedMonitor?.name;
  if (output) setFocusedOutput(output);

  const client = hypr.focusedClient;
  const win: Window | null = client
    ? {title: client.title, app_id: client.class}
    : null;
  const winKey = JSON.stringify([client?.address, win]);
  if (winKey !== lastWindow) {
    lastWindow = winKey;
    setFocusedWindow(win);
  }
}

export function connect() {
  if (hypr) return;

  hypr = AstalHyprland.get_default();
  if (!hypr) {
    console.error("hyprland: cannot reach IPC socket");
    return;
  }

  hypr.connect("event", publish);
  hypr.connect("submap", (_, name: string) =>
    setMode(name ? name.toUpperCase() : "NORMAL"),
  );
  hypr.connect("keyboard-layout", (_, _keyboard: string, layout: string) =>
    setKeyboardLayout(layout),
  );

  publish();
}

// Lua config: IPC `dispatch X` evaluates `hl.dispatch(X)`, so legacy
// dispatcher strings (and AstalHyprland's ws.focus()) no longer work
export function focusWorkspace(id: number) {
  hypr?.dispatch(`hl.dsp.focus({ workspace = "${id}" })`, "");
}

const MODS: [number, string][] = [
  [64, "Mod"],
  [4, "Ctrl"],
  [8, "Alt"],
  [1, "Shift"],
];

// Lua binds report dispatcher "__lua", so only `description` says anything
export function loadKeybinds(): Keybind[] {
  if (!hypr) return [];

  return hypr
    .get_binds()
    .filter((bind) => !bind.mouse && !bind.submap)
    .map((bind) => {
      const mods = MODS.filter(([mask]) => bind.modmask & mask).map(
        ([, name]) => name,
      );
      return {
        key: [...mods, bind.key].join("+"),
        description: bind.description.toUpperCase(),
      };
    });
}
