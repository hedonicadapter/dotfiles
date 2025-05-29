import Hyprland from "gi://AstalHyprland";
import { Variable, bind } from "astal";
import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import { getGdkMonitorFromName } from "../util";

// const hypr = Hyprland.get_default();
//
// className={bind(hypr, "focused-monitor").as((fm) => {
//   const gdkName = gdkmonitor.display.get_name();
//   const waylandName = getGdkMonitorFromName(fm.name)
//     ?.get_display()
//     .get_name();
//   const currentMonitorIsFocusedMonitor = gdkName === waylandName;
//
//   // console.log(fm.name);
//   // console.log(gdkName);
//   // console.log(waylandName);
//   // console.log(currentMonitorIsFocusedMonitor);
//   return currentMonitorIsFocusedMonitor
//     ? "Outline active-monitor"
//     : "Outline";
// })}

export default function Outline(gdkmonitor: Gdk.Monitor) {
  const hovered = Variable(false);
  return (
    <window
      className={bind(hovered).as((h) => (h ? "Outline hovered" : "Outline"))}
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
        onHover={() => hovered.set(true)}
        onHoverLost={() => hovered.set(false)}
      ></eventbox>
    </window>
  );
}
