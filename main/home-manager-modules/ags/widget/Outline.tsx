import { createComputed, createState } from "ags";
import app from "ags/gtk3/app";
import { timeout } from "ags/time";
import Astal from "gi://Astal?version=3.0";
import Gdk from "gi://Gdk?version=3.0";
import { getMonitorPlugName } from "../util";
import { focusedOutput } from "../compositor";

const SIDES = ["left", "right", "top", "bottom"];
const EDGE_FLASH_MS = 160;

// Edge pushed against with directional focus; shown on the focused output only
const [edge, setEdge] = createState<string | null>(null);
let clearEdge: ReturnType<typeof timeout> | null = null;

export function flashEdge(side: string) {
  if (!SIDES.includes(side)) return;
  clearEdge?.cancel();
  setEdge(side);
  clearEdge = timeout(EDGE_FLASH_MS, () => setEdge(null));
}

export default function Outline(gdkmonitor: Gdk.Monitor, index: number) {
  const [hovered, setHovered] = createState(false);
  const monitorName = getMonitorPlugName(gdkmonitor);

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
      ></eventbox>
    </window>
  );
}
