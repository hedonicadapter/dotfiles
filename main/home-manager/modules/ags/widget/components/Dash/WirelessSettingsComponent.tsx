import { Gtk } from "astal/gtk3";
import { Variable, bind, type Binding } from "astal";
import Bluetooth from "gi://AstalBluetooth";

const { START, CENTER, END } = Gtk.Align;

export const toggleWirelessSettings = Variable(false);

export default function () {
  const bluetooth = Bluetooth.get_default();

  return (
    <box
      className="wireless-settings"
      visible={bind(toggleWirelessSettings)}
      halign={START}
      vexpand
      vertical
    >
      <box className="panel device-panel" hexpand></box>

      <box className="panel endpoints" orientation={1} vertical={true}>
        <label
          className="heading"
          halign={START}
          valign={CENTER}
          label="MIXER"
        />
      </box>
    </box>
  );
}
