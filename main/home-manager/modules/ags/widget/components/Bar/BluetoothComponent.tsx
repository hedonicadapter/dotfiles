import Bluetooth from "gi://AstalBluetooth";
import { bind, Variable } from "astal";
import { Gtk } from "astal/gtk3";
import Hoverable from "../Hoverable";

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
    [connected, powered],
    (c: boolean, p: boolean) => {
      if (!p) return "POWERED OFF";
      if (c) {
        const amount = bluetooth.get_devices()?.length;
        return `${amount && amount + " "}CONNECTED`;
      }
      return "POWERED ON";
    },
  );

  return (
    <Hoverable
      className="bluetooth"
      main={
        <box
          className="main"
          onDestroy={() => {
            connectedPoweredIcon.drop();
            connectedPoweredLabel.drop();
          }}
          halign={Gtk.Align.START}
          valign={Gtk.Align.CENTER}
        >
          <icon
            className={bind(powered).as((b) =>
              b ? "bluetooth" : "bluetooth low",
            )}
            icon={bind(connectedPoweredIcon)}
          />
          <label label={bind(connectedPoweredLabel)} halign={Gtk.Align.START} />
        </box>
      }
      hoveredElement={
        <box className="panel" vertical>
          {bind(bluetooth, "devices").as(
            (devices) =>
              devices.length > 0 &&
              devices.map((device: any) => {
                return (
                  <box vertical>
                    <label halign={Gtk.Align.START} label={device.name || ""} />
                  </box>
                );
              }),
          )}
        </box>
      }
    />
  );
}
