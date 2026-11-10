import Gtk from "gi://Gtk?version=3.0";
import { createBinding, createState, For } from "ags";
import { execAsync } from "ags/process";
import Bluetooth, { type Device, type Adapter } from "gi://AstalBluetooth";

const { START, CENTER, END } = Gtk.Align;

export const [toggleBluetoothSettings, setBluetoothSettings] =
  createState(false);
let discoveryTimeouts: ReturnType<typeof setTimeout>[] = [];

const deviceOperationErrorNotification = (error: any) =>
  `bash -c 'notify-send "Bluetooth" "${error.toString()}"'`;

// Astal reports battery as 0..1, or -1 when the device has none
const deviceLabel = (d: Device, battery: number) =>
  [
    d.name || d.address || "Unknown",
    battery >= 0 ? `${Math.round(battery * 100)}%` : null,
  ]
    .filter(Boolean)
    .join(" ");

const connect = (d: Device) =>
  d.connect_device((_: any, res: any) => {
    try {
      d.connect_device_finish(res);
    } catch (e) {
      execAsync(deviceOperationErrorNotification(e));
    }
  });

const DevicePanel = ({
  type,
}: {
  type: "paired" | "connected" | "trusted" | "detected";
}) => {
  const bluetooth = Bluetooth.get_default();
  const adapters = createBinding(bluetooth, "adapters");

  const devices = createBinding(bluetooth, "devices").as((ds: Device[]) =>
    ds.filter((d: Device) => {
      if (type === "detected") return !d.paired && !d.connected;
      return d[type];
    }),
  );

  return (
    <box
      vertical
      // Detected keeps its SCAN button even when empty
      visible={devices.as((ds) => type === "detected" || ds.length > 0)}
      onDestroy={() => discoveryTimeouts.forEach(clearTimeout)}
    >
      <box>
        <label
          halign={START}
          valign={CENTER}
          class="heading"
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
            class={adapters.as((as: Adapter[]) =>
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
              label={adapters.as((as: Adapter[]) =>
                as.some((a: Adapter) => a.discovering) ? "SCANNING" : "SCAN",
              )}
            />
          </button>
        )}
      </box>

      {/* Plain list like audio devices; a scrollable stayed narrow */}
      <box class={type} vertical>
        <For each={devices}>
          {(d: Device) => (
            <button
              // Connected device highlighted, like the default audio device
              class={createBinding(d, "connected").as((c) =>
                c && type !== "connected" ? `${type} active` : type,
              )}
              onClicked={() => {
                switch (type) {
                  case "paired":
                  case "trusted":
                    connect(d);
                    break;
                  case "connected":
                    d.set_trusted(true);
                    break;
                  case "detected":
                    // Device.pair() blocks the shell until pairing ends
                    execAsync(["bluetoothctl", "pair", d.address])
                      .then(() => {
                        d.set_trusted(true);
                        connect(d);
                      })
                      .catch((e) =>
                        execAsync(deviceOperationErrorNotification(e)),
                      );
                    break;
                }
              }}
              valign={CENTER}
              hexpand
            >
              <label
                valign={CENTER}
                halign={START}
                class="bar-label"
                label={createBinding(d, "batteryPercentage").as((b) =>
                  deviceLabel(d, b),
                )}
              />
            </button>
          )}
        </For>
      </box>
    </box>
  );
};

export default function () {
  return (
    <box
      class="bluetooth-settings"
      visible={toggleBluetoothSettings}
      halign={START}
      vexpand
      vertical
    >
      <box class="panel device-panel" hexpand>
        <DevicePanel type="connected" />
      </box>

      <box class="panel device-panel" hexpand>
        <DevicePanel type="trusted" />
      </box>

      <box class="panel device-panel" hexpand>
        <DevicePanel type="paired" />
      </box>

      <box class="panel device-panel" hexpand>
        <DevicePanel type="detected" />
      </box>
    </box>
  );
}
