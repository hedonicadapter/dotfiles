import { Astal, Gdk } from "astal/gtk3";
import app from "ags/gtk3/app";
import { createState, createBinding } from "ags";
import { getGdkMonitorFromName } from "../util";

export default function Outline(gdkmonitor: Gdk.Monitor) {
  const [hovered, setHovered] = createState(false);
  return (
    <window
      class={hovered((h) => (h ? "Outline hovered" : "Outline"))}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.IGNORE}
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
