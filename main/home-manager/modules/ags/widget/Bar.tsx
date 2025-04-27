import { bind } from "astal";
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
import { getGdkMonitorFromName } from "../util";
import NoiseComponent from "./components/Bar/NoiseComponent";
import MinReproComponent from "./components/Bar/MinReproComponent";
import AudioSettingsComponent, {
  toggleAudioSettings,
} from "./components/Bar/AudioSettingsComponent";
import BluetoothSettingsComponent, {
  toggleBluetoothSettings,
} from "./components/Bar/BluetoothSettingsComponent";

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
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.RIGHT
      }
      application={App}
    >
      <box vexpand={false} className="bar-items" valign={START}>
        <box
          vexpand={false}
          className="left"
          hexpand
          halign={START}
          valign={START}
        >
          <box valign={START}>
            <WorkspaceComponent />
          </box>

          <box valign={START}>
            <SysTrayComponent />
          </box>

          <box valign={START}>
            <MediaComponent />
          </box>

          <box valign={START}>
            <NoiseComponent />
          </box>
        </box>

        <box className="center" halign={CENTER} valign={START}>
          <box valign={START}>
            <TitleComponent />
          </box>
        </box>

        <box className="right" hexpand halign={END} valign={START}>
          {/*<box valign={START} vertical>
            <MinReproComponent />
          </box>*/}
          <box valign={START} vertical>
            <NotificationsComponent />
          </box>
          <eventbox
            onHover={() => toggleAudioSettings.set(true)}
            onHoverLost={() => toggleAudioSettings.set(false)}
            valign={START}
          >
            <box vertical>
              <AudioComponent />
              <AudioSettingsComponent />
            </box>
          </eventbox>
          <box valign={START} vertical>
            <TemperatureComponent />
          </box>
          <eventbox
            onHover={() => toggleBluetoothSettings.set(true)}
            onHoverLost={() => toggleBluetoothSettings.set(false)}
            valign={START}
          >
            <box vertical>
              <BluetoothComponent />
              <BluetoothSettingsComponent />
            </box>
          </eventbox>
          <box valign={START} vertical>
            <WifiComponent />
          </box>
          <box valign={START} vertical>
            <TimeComponent />
          </box>
        </box>
      </box>
    </window>
  );
}
