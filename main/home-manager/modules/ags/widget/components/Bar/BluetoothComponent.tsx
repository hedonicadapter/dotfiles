import Bluetooth, { type Device } from "gi://AstalBluetooth";
import { bind, Variable } from "astal";
import { Gtk } from "astal/gtk3";

const bluetooth = Bluetooth.get_default();

export default function () {
  const powered = bind(bluetooth, "is-powered");
  const connected = bind(bluetooth, "is-connected");
  const devices = bind(bluetooth, "devices");

  const connectedPoweredIcon = Variable.derive(
    [connected, powered],
    (c: boolean, p: boolean) => {
      if (!p) return "bt-off-symbolic";
      if (c) return "bt-connected-symbolic";
      return "bt-powered-symbolic";
    },
  );

  const connectedPoweredLabel = Variable.derive(
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
    <box className="bar-item bluetooth">
      <box
        className={bind(powered).as((b) => (b ? "main" : "main low"))}
        onDestroy={() => {
          connectedPoweredIcon.drop();
          connectedPoweredLabel.drop();
        }}
        halign={Gtk.Align.START}
        valign={Gtk.Align.CENTER}
      >
        <icon icon={bind(connectedPoweredIcon)} />
        <label label={bind(connectedPoweredLabel)} halign={Gtk.Align.START} />
      </box>
    </box>
  );
}
