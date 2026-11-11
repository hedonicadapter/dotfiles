import Gtk from "gi://Gtk?version=3.0";
import cairo from "cairo";
import { type Accessor, createComputed, createState } from "ags";
import { fillingOutputs, occupiedOutputs } from "./compositor";
import { timing, tween } from "./animations";
import { session } from "./session";

// Gap between the screen edge and the bar/outline frame. Windows ignore it:
// the bar and frame float over them like a HUD
export const SCREEN_GAP = session.screenGap ?? 32;

// Active window maximized to the edges or fullscreen on this output
export const filled = (monitorName: string | undefined) =>
  fillingOutputs.as((outputs) => !!monitorName && outputs.includes(monitorName));

// One animated gap per output, shared so bar and frame move together
const gaps = new Map<string, Accessor<number>>();

export function screenGap(monitorName: string | undefined) {
  const key = monitorName ?? "";
  const cached = gaps.get(key);
  if (cached) return cached;

  const target = filled(monitorName).as((f) => (f ? 0 : SCREEN_GAP));
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

// Pointer over the bar, per output; the frame dims and brightens with it
const hovers = new Map<string, [Accessor<boolean>, (v: boolean) => void]>();

export function barHover(monitorName: string | undefined) {
  const key = monitorName ?? "";
  if (!hovers.has(key)) hovers.set(key, createState(false));
  return hovers.get(key)!;
}

// HUD fades back while windows sit under it and the bar isn't in use. A
// filled output reserves the bar's space, so nothing is under it there
export function hudDimmed(monitorName: string | undefined) {
  const [hovered] = barHover(monitorName);
  return createComputed(
    [occupiedOutputs, filled(monitorName), hovered],
    (occupied, isFilled, isHovered) =>
      !!monitorName && occupied.includes(monitorName) && !isFilled && !isHovered,
  );
}

// The bar spans the screen width but only its items take clicks, so windows
// under the empty stretches stay usable
export function inputOnlyOn(win: Gtk.Window, items: Gtk.Widget[]) {
  const update = () => {
    const region = new cairo.Region();
    for (const item of items) {
      if (!item.get_visible()) continue;
      const [ok, x, y] = item.translate_coordinates(win, 0, 0);
      if (!ok) continue;
      region.unionRectangle({
        x,
        y,
        width: item.get_allocated_width(),
        height: item.get_allocated_height(),
      });
    }
    win.input_shape_combine_region(region);
  };

  // Items resize as hover panels open and labels change
  for (const item of items) item.connect("size-allocate", update);
  win.connect("size-allocate", update);
}
