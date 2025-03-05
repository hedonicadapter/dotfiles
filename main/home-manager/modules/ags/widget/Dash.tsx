import HALComponent from "./components/Bar/Dash/HALComponent";
import { Variable, bind } from "astal";
import { App, Astal, Gtk, Gdk } from "astal/gtk3";

export default function Outline(gdkmonitor: Gdk.Monitor) {
  return (
    <window
      className="Dash"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      keymode={Astal.Keymode.ON_DEMAND}
      clickThrough={false}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.BOTTOM
      }
      application={App}
    >
      <box>
        <HALComponent />
      </box>
    </window>
  );
}
