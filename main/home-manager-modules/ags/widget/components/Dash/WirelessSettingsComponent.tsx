import Gtk from "gi://Gtk?version=3.0";
import Bluetooth from "gi://AstalBluetooth";
import { createState, createBinding } from "ags";

const { START, CENTER, END } = Gtk.Align;

export const [toggleWirelessSettings, setToggleWirelessSettings] =
  createState(false);

export default function () {
  const bluetooth = Bluetooth.get_default();

  return (
    <box
      class="wireless-settings"
      visible={createBinding(toggleWirelessSettings)}
      halign={START}
      vexpand
      vertical
    >
      <box class="panel device-panel" hexpand></box>

      <box class="panel endpoints" orientation={1} vertical={true}>
        <label class="heading" halign={START} valign={CENTER} label="MIXER" />
      </box>
    </box>
  );
}
