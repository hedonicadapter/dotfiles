import { Variable, bind } from "astal";
import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import TimeComponent from "./components/Bar/TimeComponent";
import SysTrayComponent from "./components/Bar/SysTrayComponent";
import WifiComponent from "./components/Bar/WifiComponent";
import WorkspaceComponent from "./components/Bar/WorkspaceComponent";
import TitleComponent from "./components/Bar/TitleComponent";
import NotificationsComponent from "./components/Bar/NotificationsComponent";

export default function Bar(gdkmonitor: Gdk.Monitor) {
  const hovered = Variable(false);
  const { START, END, CENTER } = Gtk.Align;

  return (
    <window
      className={bind(hovered).as((h) => (h ? "Bar hovered" : "Bar"))}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.RIGHT
      }
      application={App}
    >
      <eventbox
        className={bind(hovered).as((h) => (h ? "hovered" : ""))}
        onHover={() => hovered.set(true)}
        onHoverLost={() => hovered.set(false)}
      >
        <centerbox className="bar-items" valign={START}>
          <box hexpand halign={START}>
            <box valign={START}>
              <WorkspaceComponent />
            </box>

            <box valign={START}>
              <SysTrayComponent />
            </box>
          </box>

          <box halign={CENTER}>
            <box valign={START}>
              <TitleComponent />
            </box>
          </box>

          <box className="main-menu" hexpand halign={END}>
            <box valign={START}>
              <NotificationsComponent />
            </box>
            <box valign={START}>
              <WifiComponent />
            </box>

            <box valign={START}>
              <TimeComponent />
            </box>
          </box>
        </centerbox>
      </eventbox>
    </window>
  );
}