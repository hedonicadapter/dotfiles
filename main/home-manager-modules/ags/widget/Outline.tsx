import { createComputed, createState } from "ags";
import app from "ags/gtk3/app";
import { timeout } from "ags/time";
import { readFile } from "ags/file";
import Astal from "gi://Astal?version=3.0";
import Gdk from "gi://Gdk?version=3.0";
import Gtk from "gi://Gtk?version=3.0";
import { getMonitorPlugName } from "../util";
import { focusedOutput } from "../compositor";
import { screenGap } from "../layout";

const SIDES = ["left", "right", "top", "bottom"];
// Written by home.nix from compositor/animations.nix
function edgeHoldMs() {
  try {
    const flash = JSON.parse(readFile(`${SRC}/animations.json`)).edgeFlash;
    if (typeof flash?.holdMs === "number") return flash.holdMs;
  } catch (e) {
    console.error("Outline: no animations.json, using default edge hold", e);
  }
  return 160;
}
const EDGE_HOLD_MS = edgeHoldMs();

// Edge pushed against with directional focus; shown on the focused output only
const [edge, setEdge] = createState<string | null>(null);
let clearEdge: ReturnType<typeof timeout> | null = null;

export function flashEdge(side: string) {
  if (!SIDES.includes(side)) return;
  clearEdge?.cancel();
  setEdge(side);
  clearEdge = timeout(EDGE_HOLD_MS, () => setEdge(null));
}

// Ruler ticks along the inside of the frame, like plot axes. Minor every
// TICK_STEP px, major every TICK_MAJOR ticks. The top edge is left to the bar
const TICK_STEP = 24;
const TICK_MAJOR = 5;
const TICK_MINOR_LEN = 3;
const TICK_MAJOR_LEN = 7;
// Side ticks start below the bar's tabs
const TICK_TOP_CLEAR = 56;

function drawTicks(area: Gtk.DrawingArea, cr: any) {
  const w = area.get_allocated_width();
  const h = area.get_allocated_height();
  // Color comes from CSS (.ticks), so it follows the palette and focus
  const c = area.get_style_context().get_color(area.get_state_flags());
  cr.setSourceRGBA(c.red, c.green, c.blue, c.alpha);

  const len = (i: number) =>
    i % TICK_MAJOR === 0 ? TICK_MAJOR_LEN : TICK_MINOR_LEN;

  for (let i = 1; i * TICK_STEP < h; i++) {
    const y = h - i * TICK_STEP;
    if (y < TICK_TOP_CLEAR) break;
    cr.rectangle(0, y, len(i), 1);
    cr.rectangle(w - len(i), y, len(i), 1);
  }
  for (let i = 1; i * TICK_STEP < w; i++) {
    const x = i * TICK_STEP;
    cr.rectangle(x, h - len(i), 1, len(i));
  }
  cr.fill();
  cr.$dispose();
  return false;
}

export default function Outline(gdkmonitor: Gdk.Monitor, index: number) {
  const [hovered, setHovered] = createState(false);
  const monitorName = getMonitorPlugName(gdkmonitor);
  const gap = screenGap(monitorName);

  const className = createComputed(
    [hovered, focusedOutput, edge],
    (isHovered, output, side) => {
      const active = !!output && output === monitorName;
      return [
        "Outline",
        active ? "active-monitor" : "",
        isHovered ? "hovered" : "",
        active && side ? `edge-${side}` : "",
      ]
        .filter(Boolean)
        .join(" ");
    },
  );

  return (
    <window
      name={`outline-${index}`}
      class={className}
      gdkmonitor={gdkmonitor}
      marginTop={gap}
      marginBottom={gap}
      marginLeft={gap}
      marginRight={gap}
      exclusivity={Astal.Exclusivity.IGNORE}
      // click-through is not a GObject property — v3 has no clickThrough prop
      $={(self) => Astal.widget_set_click_through(self, true)}
      layer={Astal.Layer.OVERLAY}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.RIGHT |
        Astal.WindowAnchor.BOTTOM
      }
      application={app}
    >
      <eventbox
        hexpand
        vexpand
        onHover={() => setHovered(true)}
        onHoverLost={() => setHovered(false)}
      >
        <drawingarea
          class="ticks"
          hexpand
          vexpand
          $={(self) => self.connect("draw", drawTicks)}
        />
      </eventbox>
    </window>
  );
}
