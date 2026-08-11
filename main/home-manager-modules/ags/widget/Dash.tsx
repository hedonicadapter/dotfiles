import HALComponent from "./components/Dash/HALComponent";
import { Astal, Gdk } from "ags/gtk3";
import app from "ags/gtk3/app";

export default function Outline(gdkmonitor: Gdk.Monitor) {
  return (
    <window
      class="Dash"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self) => Astal.widget_set_click_through(self, true)}
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
