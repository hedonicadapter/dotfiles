import { Variable, bind } from "astal";
import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import Hyprland from "gi://AstalHyprland";
import TimeComponent from "./components/Bar/TimeComponent";
import SysTrayComponent from "./components/Bar/SysTrayComponent";
import WifiComponent from "./components/Bar/WifiComponent";
import WorkspaceComponent from "./components/Bar/WorkspaceComponent";
import TitleComponent from "./components/Bar/TitleComponent";
import NotificationsComponent from "./components/Bar/NotificationsComponent";
import AudioComponent from "./components/Bar/AudioComponent";
import MediaComponent from "./components/Bar/MediaComponent";
import TemperatureComponent from "./components/Bar/TemperatureComponent";
import BluetoothComponent from "./components/Bar/BluetoothComponent";
import ModeComponent from "./components/Bar/ModeComponent";
import { getGdkMonitorFromName } from "../util";

const hypr = Hyprland.get_default();

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { START, END, CENTER } = Gtk.Align;

  return (
    <window
      className={bind(hypr, "focused-monitor").as((fm) => {
        const gdkName = gdkmonitor.display.get_name();
        const waylandName = getGdkMonitorFromName(fm.name)
          ?.get_display()
          .get_name();
        const currentMonitorIsFocusedMonitor = gdkName === waylandName;

        return currentMonitorIsFocusedMonitor ? "Bar active-monitor" : "Bar";
      })}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.RIGHT
      }
      application={App}
    >
      <centerbox className="bar-items" valign={START}>
        <box className="left" hexpand halign={START}>
          <box valign={START}>
            <WorkspaceComponent />
          </box>
          <box valign={START}>
            <ModeComponent />
          </box>

          <box valign={START}>
            <SysTrayComponent />
          </box>

          <box valign={START}>
            <MediaComponent />
          </box>
        </box>

        <box className="center" halign={CENTER}>
          <box valign={START}>
            <TitleComponent />
          </box>
        </box>

        <box className="right" hexpand halign={END}>
          <box valign={START}>
            <NotificationsComponent />
          </box>
          <box valign={START}>
            <AudioComponent />
          </box>
          <box valign={START}>
            <TemperatureComponent />
          </box>
          <box valign={START}>
            <BluetoothComponent />
          </box>
          <box valign={START}>
            <WifiComponent />
          </box>
          <box valign={START}>
            <TimeComponent />
          </box>
        </box>
      </centerbox>
    </window>
  );
}
