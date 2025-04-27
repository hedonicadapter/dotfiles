import { Gtk } from "astal/gtk3";
import { Variable, bind, type Binding } from "astal";
import { execAsync } from "astal/process";
import Bluetooth, { type Device, type Adapter } from "gi://AstalBluetooth";

const { START, CENTER, END } = Gtk.Align;

export const toggleBluetoothSettings = Variable(false);
let discoveryTimeouts: ReturnType<typeof setTimeout>[] = [];

const deviceOperationErrorNotification = (error: any) =>
  `bash -c 'notify-send "Bluetooth" "${error.toString()}"'`;

const DevicePanel = ({
  type,
}: {
  type: "paired" | "connected" | "trusted" | "detected";
}) => {
  const bluetooth = Bluetooth.get_default();

  return (
    <box vertical onDestroy={() => discoveryTimeouts.forEach(clearTimeout)}>
      <box>
        <label
          halign={START}
          valign={CENTER}
          className="heading"
          label={type.toUpperCase()}
          maxWidthChars={50}
          ellipsize={3}
          truncate
          hexpand
        />

        {type === "detected" && (
          <button
            valign={CENTER}
            halign={END}
            className={bind(bluetooth, "adapters").as((as: Adapter[]) =>
              as.some((a: Adapter) => a.discovering) ? "discovering" : "",
            )}
            onClicked={() => {
              bluetooth.adapters?.forEach((a: Adapter) => {
                discoveryTimeouts.forEach(clearTimeout);
                a.start_discovery();

                const discoveryTimeout = setTimeout(() => {
                  a.stop_discovery();
                }, 6000);
                discoveryTimeouts.push(discoveryTimeout);
              });
            }}
          >
            <label
              label={bind(bluetooth, "adapters").as((as: Adapter[]) =>
                as.some((a: Adapter) => a.discovering) ? "SCANNING" : "SCAN",
              )}
            />
          </button>
        )}
      </box>

      <scrollable heightRequest={80} hscroll={Gtk.PolicyType.AUTOMATIC}>
        <box className={type} vertical>
          {bind(bluetooth, "devices").as((ds: Device[]) =>
            ds
              .filter((d: Device) => {
                if (type === "detected")
                  return !d.paired && !d.connected && !d.paired;
                else return d[type];
              })
              .map((d: Device) => {
                const name = d.name;
                const battery = d.batteryPercentage;
                const finalLabel = [
                  name !== undefined ? name : null,
                  battery !== undefined ? `${battery}%` : null,
                ]
                  .filter(Boolean)
                  .join(" ");

                return (
                  <button
                    className={type}
                    onClicked={() => {
                      switch (type) {
                        case "paired":
                        case "trusted":
                          d.connect_device((_: any, res: any) => {
                            try {
                              d.connect_device_finish(res);
                            } catch (e) {
                              execAsync(deviceOperationErrorNotification(e));
                            }
                          });
                          break;
                        case "connected":
                          d.set_trusted(true);
                          break;
                        default:
                          break;
                      }
                    }}
                    valign={CENTER}
                    hexpand
                  >
                    <label
                      valign={CENTER}
                      halign={START}
                      className="bar-label"
                      label={finalLabel.trim() || d.address || "Unknown"}
                    />
                  </button>
                );
              }),
          )}
        </box>
      </scrollable>
    </box>
  );
};

export default function () {
  return (
    <box
      className="bluetooth-settings"
      visible={bind(toggleBluetoothSettings)}
      halign={START}
      vexpand
      vertical
    >
      <box className="panel device-panel" hexpand>
        <DevicePanel type="connected" />
      </box>

      <box className="panel device-panel" hexpand>
        <DevicePanel type="trusted" />
      </box>

      <box className="panel device-panel" hexpand>
        <DevicePanel type="paired" />
      </box>

      <box className="panel device-panel" hexpand>
        <DevicePanel type="detected" />
      </box>
    </box>
  );
}
