import { createComputed, createState } from "ags";
import app from "ags/gtk3/app";
import Astal from "gi://Astal?version=3.0";
import Gdk from "gi://Gdk?version=3.0";
import { getMonitorPlugName } from "../util";
import { focusedOutput } from "../niri";

export default function Outline(gdkmonitor: Gdk.Monitor, index: number) {
  const [hovered, setHovered] = createState(false);
  const monitorName = getMonitorPlugName(gdkmonitor);

  const className = createComputed(
    [hovered, focusedOutput],
    (isHovered, output) =>
      [
        "Outline",
        output && output === monitorName ? "active-monitor" : "",
        isHovered ? "hovered" : "",
      ]
        .filter(Boolean)
        .join(" "),
  );

  return (
    <window
      name={`outline-${index}`}
      class={className}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
      clickThrough={true}
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
