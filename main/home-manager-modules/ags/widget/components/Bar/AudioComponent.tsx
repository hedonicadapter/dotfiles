import { Variable, bind, type Binding } from "astal";
import { Gtk } from "astal/gtk3";
import Wp, { type Device, type Endpoint, type Stream } from "gi://AstalWp";
import Hoverable from "../Hoverable";
import { execAsync } from "astal/process";

const { START, CENTER } = Gtk.Align;

const wp = Wp.get_default();
const audio = wp?.audio;
const speaker = audio.defaultSpeaker!;
const mic = audio.defaultMicrophone!;

const deviceAddedNotification = (deviceName: string) =>
  `bash -c 'notify-send "Device added" "${deviceName}" --action=use=use'`;
const deviceChangedNotification = (deviceName: string) =>
  `bash -c 'notify-send "Device changed to ${deviceName}"'`;
const deviceChangeFailedNotification = (deviceName: string) =>
  `bash -c 'notify-send "Failed setting device to ${deviceName}"'`;
const deviceRemovedNotification = (deviceName: string) =>
  `bash -c 'notify-send "Device removed" "${deviceName}"'`;

const deviceAddedConnection = wp.connect(
  "device-added",
  async (_: any, device: Device) => {
    try {
      const res = await execAsync(deviceAddedNotification(device.description));

      if (res === "use") {
        console.log(device.id);
        const res = await execAsync(`bash -c 'wpctl set-default ${device.id}'`);
        await execAsync(deviceChangedNotification(device.description));
      }
    } catch (e) {
      console.log(e);
    }
  },
);
const deviceRemovedConnection = wp.connect(
  "device-removed",
  async (_: any, device: Device) =>
    await execAsync(deviceRemovedNotification(device.description)),
);

export const Bar = ({ stream }: { stream: any }) => {
  return (
    <box>
      {bind(stream, "volume").as((volume) =>
        Array.from({ length: 5 }).map((_, i) => {
          const tenths = Math.round(parseFloat(volume) * 5);
          const fill = i <= tenths;

          return (
            <button
              onClicked={() => {
                const newVolume = i * 0.2;

                stream.volume = newVolume;
              }}
              className={bind(stream, "muted").as((b) =>
                b ? "bar muted" : "bar",
              )}
              valign={CENTER}
            >
              <label
                className={
                  tenths < 2
                    ? "low"
                    : tenths < 4
                      ? "mid"
                      : tenths >= 4
                        ? "high"
                        : ""
                }
                halign={START}
                label={fill ? "▮" : "▯"}
                valign={CENTER}
              />
            </button>
          );
        }),
      )}
    </box>
  );
};

export default function () {
  return (
    <box
      className="audio"
      valign={CENTER}
      halign={START}
      onDestroy={() => {
        wp.disconnect(deviceAddedConnection);
        wp.disconnect(deviceRemovedConnection);
      }}
    >
      <box className="bar-item" valign={CENTER}>
        <button valign={CENTER} onClicked={() => (mic.mute = !mic.mute)}>
          <label valign={CENTER} className="bar-label" label="IN:" />
        </button>

        {bind(mic, "muted").as((m) =>
          m ? (
            <button valign={CENTER} onClicked={() => (mic.mute = false)}>
              <label label="MUTED" valign={CENTER} />
            </button>
          ) : (
            <Bar stream={mic} />
          ),
        )}
      </box>

      <box className="bar-item" valign={CENTER}>
        <button
          valign={CENTER}
          onClicked={() => (speaker.mute = !speaker.mute)}
        >
          <label valign={CENTER} className="bar-label" label="OUT:" />
        </button>

        {bind(speaker, "muted").as((m) =>
          m ? (
            <button valign={CENTER} onClicked={() => (speaker.mute = false)}>
              <label valign={CENTER} label="MUTED" />
            </button>
          ) : (
            <Bar stream={speaker} />
          ),
        )}
      </box>
    </box>
  );
}
