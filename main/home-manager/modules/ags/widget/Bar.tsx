import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import TimeComponent from "./components/TimeComponent";
import SysTrayComponent from "./components/SysTrayComponent";
import WifiComponent from "./components/WifiComponent";
import WorkspaceComponent from "./components/WorkspaceComponent";
import TitleComponent from "./components/TitleComponent";

export default function Bar(gdkmonitor: Gdk.Monitor) {
  return (
    <window
      className="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.RIGHT
      }
      application={App}
    >
      <centerbox valign={Gtk.Align.START}>
        <box hexpand halign={Gtk.Align.START}>
          <WorkspaceComponent />
          <SysTrayComponent />
        </box>
        <box halign={Gtk.Align.CENTER}>
          <TitleComponent />
        </box>
        <box className="main-menu" hexpand halign={Gtk.Align.END}>
          <WifiComponent />

          <TimeComponent />
        </box>
      </centerbox>
    </window>
  );
}
