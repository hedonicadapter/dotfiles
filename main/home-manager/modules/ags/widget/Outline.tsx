import Hyprland from "gi://AstalHyprland";
import { Variable, bind } from "astal";
import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import { getGdkMonitorFromName } from "../util";

const hypr = Hyprland.get_default();

export default function Outline(gdkmonitor: Gdk.Monitor) {
  return (
    <window
      // className={bind(hovered).as((h) => (h ? "Screen hovered" : "Screen"))}
      className={bind(hypr, "focused-monitor").as((fm) => {
        const gdkName = gdkmonitor.display.get_name();
        const waylandName = getGdkMonitorFromName(fm.name)
          ?.get_display()
          .get_name();
        const currentMonitorIsFocusedMonitor = gdkName === waylandName;

        return currentMonitorIsFocusedMonitor
          ? "Screen active-monitor"
          : "Screen";
      })}
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
    ></window>
  );
}
