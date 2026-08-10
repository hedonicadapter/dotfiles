import { Variable, bind } from "astal";
import { App, Astal, Gdk } from "astal/gtk3";
import { getMonitorPlugName } from "../util";
import { focusedOutput } from "../niri";

export default function Outline(gdkmonitor: Gdk.Monitor) {
  const hovered = Variable(false);
  const monitorName = getMonitorPlugName(gdkmonitor);

  const className = Variable.derive(
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
      className={bind(className)}
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
      application={App}
    >
      <eventbox
        hexpand
        vexpand
        onDestroy={() => {
          className.drop();
          hovered.drop();
        }}
        onHover={() => hovered.set(true)}
        onHoverLost={() => hovered.set(false)}
      ></eventbox>
    </window>
  );
}
