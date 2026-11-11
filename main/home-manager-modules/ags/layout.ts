import Gtk from "gi://Gtk?version=3.0";
import { type Accessor, createState } from "ags";
import { fillingOutputs } from "./compositor";
import { timing, tween } from "./animations";
import { session } from "./session";

// Gap between the screen edge and the bar/outline frame, on every side
export const SCREEN_GAP = session.screenGap ?? 20;

// gtk-layer-shell sets the bar's reserved space directly. Loaded loosely so
// a missing typelib only costs the smooth bar move, not the whole shell
let LayerShell: any = null;
try {
  const gi = (globalThis as any).imports.gi;
  gi.versions.GtkLayerShell = "0.1";
  LayerShell = gi.GtkLayerShell;
} catch (e) {
  console.error("layout: no GtkLayerShell, bar gap reflows per frame", e);
}

// The frame hugs the screen edge while the active window fills the output.
// 1 = gapped, 0 = at the edge
const targetOpen = (monitorName: string | undefined) =>
  fillingOutputs.as((outputs) =>
    monitorName && outputs.includes(monitorName) ? 0 : 1,
  );

const opens = new Map<string, Accessor<number>>();

function gapOpen(monitorName: string | undefined) {
  const key = monitorName ?? "";
  const cached = opens.get(key);
  if (cached) return cached;

  const target = targetOpen(monitorName);
  const [open, setOpen] = createState(target.peek());
  let cancel = () => {};
  target.subscribe(() => {
    cancel();
    cancel = tween(open.peek(), target.peek(), timing("screenGap"), setOpen);
  });

  opens.set(key, open);
  return open;
}

// Animated margin for the bar and frame on one output, shared so they move
// together
export function screenGap(monitorName: string | undefined) {
  return gapOpen(monitorName).as((o) => Math.round(o * SCREEN_GAP));
}

// Reserve the bar's space for the target gap right away, so windows resize
// once (the compositor animates that) while the bar itself slides. With
// auto exclusive zone the margin tween would reflow every window per frame.
// The space under the bar is the compositor's: a negative niri top strut,
// Hyprland's top outer gap
export function reserveBarSpace(
  win: Gtk.Window,
  monitorName: string | undefined,
) {
  if (!LayerShell) return;

  const target = targetOpen(monitorName);
  const update = () =>
    LayerShell.set_exclusive_zone(
      win,
      win.get_allocated_height() + target.peek() * SCREEN_GAP,
    );

  // Hover panels change the bar's height
  win.connect("size-allocate", update);
  const unsubscribe = target.subscribe(update);
  win.connect("destroy", unsubscribe);
  update();
}
