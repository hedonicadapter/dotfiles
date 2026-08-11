import { createBinding, With } from "ags";
import Gtk from "gi://Gtk?version=3.0";
import Wp, { type Device } from "gi://AstalWp";
import { execAsync } from "ags/process";

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

// Five segments; each reacts to volume rather than rebuilding the row
export const Bar = ({ stream }: { stream: any }) => {
  const volume = createBinding(stream, "volume");
  const muted = createBinding(stream, "muted");

  return (
    <box>
      {Array.from({ length: 5 }).map((_, i) => (
        <button
          onClicked={() => {
            stream.volume = i * 0.2;
          }}
          class={muted.as((b) => (b ? "bar muted" : "bar"))}
          valign={CENTER}
        >
          <label
            class={volume.as((v) => {
              const tenths = Math.round(parseFloat(v) * 5);
              return tenths < 2 ? "low" : tenths < 4 ? "mid" : "high";
            })}
            halign={START}
            label={volume.as((v) =>
              i <= Math.round(parseFloat(v) * 5) ? "▮" : "▯",
            )}
            valign={CENTER}
          />
        </button>
      ))}
    </box>
  );
};

export default function () {
  return (
    <box
      class="audio"
      valign={CENTER}
      halign={START}
      onDestroy={() => {
        wp.disconnect(deviceAddedConnection);
        wp.disconnect(deviceRemovedConnection);
      }}
    >
      <box class="bar-item" valign={CENTER}>
        <button valign={CENTER} onClicked={() => (mic.mute = !mic.mute)}>
          <label valign={CENTER} class="bar-label" label="IN:" />
        </button>

        <With value={createBinding(mic, "muted")}>
          {(m) =>
            m ? (
              <button valign={CENTER} onClicked={() => (mic.mute = false)}>
                <label label="MUTED" valign={CENTER} />
              </button>
            ) : (
              <Bar stream={mic} />
            )
          }
        </With>
      </box>

      <box class="bar-item" valign={CENTER}>
        <button
          valign={CENTER}
          onClicked={() => (speaker.mute = !speaker.mute)}
        >
          <label valign={CENTER} class="bar-label" label="OUT:" />
        </button>

        <With value={createBinding(speaker, "muted")}>
          {(m) =>
            m ? (
              <button valign={CENTER} onClicked={() => (speaker.mute = false)}>
                <label valign={CENTER} label="MUTED" />
              </button>
            ) : (
              <Bar stream={speaker} />
            )
          }
        </With>
      </box>
    </box>
  );
}
