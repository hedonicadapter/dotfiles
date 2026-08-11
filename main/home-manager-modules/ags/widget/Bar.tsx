import app from "ags/gtk3/app";
import Astal from "gi://Astal?version=3.0";
import Gtk from "gi://Gtk?version=3.0";
import Gdk from "gi://Gdk?version=3.0";
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
import { getMonitorPlugName } from "../util";
import NoiseComponent from "./components/Bar/NoiseComponent";
import MinReproComponent from "./components/Bar/MinReproComponent";
import AudioSettingsComponent, {
  setAudioSettings,
} from "./components/Bar/AudioSettingsComponent";
import BluetoothSettingsComponent, {
  setBluetoothSettings,
} from "./components/Bar/BluetoothSettingsComponent";
import { focusedOutput } from "../niri";

export default function Bar(gdkmonitor: Gdk.Monitor, index: number) {
  const { START, END, CENTER } = Gtk.Align;
  const monitorName = getMonitorPlugName(gdkmonitor);

  return (
    <window
      name={`bar-${index}`}
      class={focusedOutput.as((output) =>
        output && output === monitorName ? "Bar active-monitor" : "Bar",
      )}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.RIGHT
      }
      application={app}
    >
      <box vexpand={false} class="bar-items" valign={START}>
        <box
          vexpand={false}
          class="left"
          hexpand
          halign={START}
          valign={START}
        >
          <box valign={START}>
            <WorkspaceComponent monitor={monitorName} />
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

        <box class="center" halign={CENTER} valign={START}>
          <box valign={START}>
            <TitleComponent />
          </box>
        </box>

        <box class="right" hexpand halign={END} valign={START}>
          {/*<box valign={START} vertical>
            <MinReproComponent />
          </box>*/}
          <box valign={START} vertical>
            <NotificationsComponent />
          </box>
          <eventbox
            onHover={() => setAudioSettings(true)}
            onHoverLost={() => setAudioSettings(false)}
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
            onHover={() => setBluetoothSettings(true)}
            onHoverLost={() => setBluetoothSettings(false)}
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
