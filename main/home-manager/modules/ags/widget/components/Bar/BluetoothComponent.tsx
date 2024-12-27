import Bluetooth from "gi://AstalBluetooth";
import { bind, Variable } from "astal";
import { Gtk } from "astal/gtk3";

const bluetooth = Bluetooth.get_default();

export default function () {
  const hovered = Variable(false);
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
    <eventbox
      className={bind(hovered).as((h) => (h ? "hovered" : ""))}
      onHover={() => hovered.set(true)}
      onHoverLost={() => hovered.set(false)}
      onDestroy={() => {
        connectedPoweredIcon.drop();
        connectedPoweredLabel.drop();
      }}
    >
      <box className="bar-item bluetooth" vertical>
        <box>
          <icon
            className={bind(powered).as((b) =>
              b ? "bluetooth" : "bluetooth low",
            )}
            icon={bind(connectedPoweredIcon)}
          />
          <label visible={bind(hovered)} label={bind(connectedPoweredLabel)} />
        </box>

        <box className="panel" visible={bind(hovered)} vertical>
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
      </box>
    </eventbox>
  );
}
