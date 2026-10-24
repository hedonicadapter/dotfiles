// Compositor-agnostic shell state. Backends write it, widgets read it via
// ../compositor.ts.
import { createState } from "ags";

export type Workspace = {
  id: number;
  // Order within its output
  idx: number;
  name: string | null;
  output: string | null;
  is_active: boolean;
  is_focused: boolean;
  is_urgent: boolean;
};

export type Window = {
  title: string | null;
  app_id: string | null;
};

export type Keybind = {
  key: string;
  description: string;
};

export type Backend = {
  connect(): void;
  focusWorkspace(id: number): void;
  loadKeybinds(): Keybind[];
};

export const [workspaces, setWorkspaces] = createState<Workspace[]>([]);
export const [focusedWorkspace, setFocusedWorkspace] =
  createState<Workspace | null>(null);
export const [focusedOutput, setFocusedOutput] = createState<string | null>(null);
export const [focusedWindow, setFocusedWindow] = createState<Window | null>(null);
// Modal state for the bar: niri overview, Hyprland submap
export const [mode, setMode] = createState("NORMAL");
export const [keyboardLayout, setKeyboardLayout] = createState("");

export function publishWorkspaces(list: Workspace[]) {
  // Derived state first — subscribers of `workspaces` read it in the same tick
  const focused = list.find((ws) => ws.is_focused) ?? null;
  setFocusedWorkspace(focused);
  if (focused?.output) setFocusedOutput(focused.output);

  setWorkspaces(list);
}
