import HALComponent from "./components/Dash/HALComponent";
import app from "ags/gtk3/app";
import Astal from "gi://Astal?version=3.0";
import Gdk from "gi://Gdk?version=3.0";

export default function Dash(gdkmonitor: Gdk.Monitor, index: number) {
  return (
    <window
      name={`dash-${index}`}
      class="Dash"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={
        Astal.WindowAnchor.TOP |
        Astal.WindowAnchor.LEFT |
        Astal.WindowAnchor.BOTTOM
      }
      application={app}
    >
      <box>
        <HALComponent />
      </box>
    </window>
  );
}
