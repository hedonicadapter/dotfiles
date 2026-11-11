import Gtk from "gi://Gtk?version=3.0";
import { type Accessor, createState } from "ags";
import { fillingOutputs } from "./compositor";
import { timing, tween } from "./animations";

// Gap between the screen edge and the bar/outline frame
export const SCREEN_GAP = 20;

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

// The frame hugs the screen edge while the active window fills the output
const targetGap = (monitorName: string | undefined) =>
  fillingOutputs.as((outputs) =>
    monitorName && outputs.includes(monitorName) ? 0 : SCREEN_GAP,
  );

// One animated gap per output, shared so bar and frame move together
const gaps = new Map<string, Accessor<number>>();

export function screenGap(monitorName: string | undefined) {
  const key = monitorName ?? "";
  const cached = gaps.get(key);
  if (cached) return cached;

  const target = targetGap(monitorName);
  const [gap, setGap] = createState(target.peek());
  let cancel = () => {};
  target.subscribe(() => {
    cancel();
    cancel = tween(gap.peek(), target.peek(), timing("screenGap"), (v) =>
      setGap(Math.round(v)),
    );
  });

  gaps.set(key, gap);
  return gap;
}

// Reserve the bar's space for the target gap right away, so windows resize
// once (the compositor animates that) while the bar itself slides. With
// auto exclusive zone the margin tween would reflow every window per frame
export function reserveBarSpace(
  win: Gtk.Window,
  monitorName: string | undefined,
) {
  if (!LayerShell) return;

  const target = targetGap(monitorName);
  const update = () =>
    LayerShell.set_exclusive_zone(
      win,
      win.get_allocated_height() + target.peek(),
    );

  // Hover panels change the bar's height
  win.connect("size-allocate", update);
  const unsubscribe = target.subscribe(update);
  win.connect("destroy", unsubscribe);
  update();
}
