import Bluetooth, { type Device } from "gi://AstalBluetooth";
import { createBinding, createComputed } from "ags";
import Gtk from "gi://Gtk?version=3.0";

const bluetooth = Bluetooth.get_default();

export default function () {
  const powered = createBinding(bluetooth, "is-powered");
  const connected = createBinding(bluetooth, "is-connected");
  const devices = createBinding(bluetooth, "devices");

  const connectedPoweredIcon = createComputed(
    [connected, powered],
    (c: boolean, p: boolean) => {
      if (!p) return "bt-off-symbolic";
      if (c) return "bt-connected-symbolic";
      return "bt-powered-symbolic";
    },
  );

  const connectedPoweredLabel = createComputed(
    [connected, powered, devices],
    (c: boolean, p: boolean, ds: Device[]) => {
      if (!p) return "POWERED OFF";
      if (c) {
        const connectedDevices = ds.filter((d: Device) => d.connected);
        const amount = connectedDevices.length;
        return `${amount && amount + " "}CONNECTED`;
      }
      return "POWERED ON";
    },
  );

  return (
    <box class="bar-item bluetooth">
      <box
        class={powered.as((b) => (b ? "main" : "main low"))}
        halign={Gtk.Align.START}
        valign={Gtk.Align.CENTER}
      >
        <icon icon={connectedPoweredIcon} />
        <label label={connectedPoweredLabel} halign={Gtk.Align.START} />
      </box>
    </box>
  );
}
