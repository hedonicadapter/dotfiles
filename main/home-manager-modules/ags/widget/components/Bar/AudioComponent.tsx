import { createBinding, With } from "ags";
import Gtk from "gi://Gtk?version=3.0";
import Wp, { type Device, type Endpoint } from "gi://AstalWp";
import { execAsync } from "ags/process";
import { timeout } from "ags/time";

const { START, CENTER } = Gtk.Align;

const wp = Wp.get_default();
const audio = wp?.audio ?? null;

const deviceAddedNotification = (deviceName: string) =>
  `bash -c 'notify-send "Device added" "${deviceName}" --action=use=use'`;
const deviceChangedNotification = (deviceName: string) =>
  `bash -c 'notify-send "Device changed to ${deviceName}"'`;
const deviceChangeFailedNotification = (deviceName: string) =>
  `bash -c 'notify-send "Failed setting device to ${deviceName}"'`;
const deviceRemovedNotification = (deviceName: string) =>
  `bash -c 'notify-send "Device removed" "${deviceName}"'`;

// device-added fires for every device already present when wireplumber is
// first enumerated, which notified once per device on every startup
let enumerated = false;
let deviceAddedConnection: number | null = null;
let deviceRemovedConnection: number | null = null;

if (wp) {
  timeout(3000, () => (enumerated = true));

  deviceAddedConnection = wp.connect(
    "device-added",
    async (_: any, device: Device) => {
      if (!enumerated) return;

      try {
        const res = await execAsync(
          deviceAddedNotification(device.description),
        );

        if (res === "use") {
          await execAsync(`bash -c 'wpctl set-default ${device.id}'`);
          await execAsync(deviceChangedNotification(device.description));
        }
      } catch (e) {
        console.log(e);
      }
    },
  );

  deviceRemovedConnection = wp.connect(
    "device-removed",
    async (_: any, device: Device) =>
      await execAsync(deviceRemovedNotification(device.description)),
  );
}

const SEGMENTS = 5;

// Filled segments, 0..SEGMENTS
const level = (volume: number) => Math.round(volume * SEGMENTS);

// Each reacts to volume rather than rebuilding the row. Segment i sets
// (i + 1) / SEGMENTS, so the last one reaches 100% and silence shows empty
export const Bar = ({ stream }: { stream: any }) => {
  const volume = createBinding(stream, "volume");
  const muted = createBinding(stream, "mute");

  return (
    <box>
      {Array.from({ length: SEGMENTS }).map((_, i) => (
        <button
          onClicked={() => {
            stream.volume = (i + 1) / SEGMENTS;
          }}
          class={muted.as((b) => (b ? "bar muted" : "bar"))}
          valign={CENTER}
        >
          <label
            class={volume.as((v) => {
              const l = level(v);
              return l < 2 ? "low" : l < 4 ? "mid" : "high";
            })}
            halign={START}
            label={volume.as((v) => (i < level(v) ? "▮" : "▯"))}
            valign={CENTER}
          />
        </button>
      ))}
    </box>
  );
};

const EndpointControls = ({
  label,
  endpoint,
}: {
  label: string;
  endpoint: Endpoint;
}) => (
  <box class="bar-item" valign={CENTER}>
    <button
      valign={CENTER}
      onClicked={() => (endpoint.mute = !endpoint.mute)}
    >
      <label valign={CENTER} class="bar-label" label={label} />
    </button>

    <With value={createBinding(endpoint, "mute")}>
      {(m) =>
        m ? (
          <button valign={CENTER} onClicked={() => (endpoint.mute = false)}>
            <label label="MUTED" valign={CENTER} />
          </button>
        ) : (
          <Bar stream={endpoint} />
        )
      }
    </With>
  </box>
);

export default function AudioComponent() {
  // Without wireplumber this module would throw at import and take the bar
  // down with it
  if (!audio) return <box />;

  return (
    <box
      class="audio"
      valign={CENTER}
      halign={START}
      onDestroy={() => {
        if (deviceAddedConnection !== null) wp!.disconnect(deviceAddedConnection);
        if (deviceRemovedConnection !== null)
          wp!.disconnect(deviceRemovedConnection);
      }}
    >
      {/* Rebind when the default device changes, instead of capturing it once */}
      <With value={createBinding(audio, "default-microphone")}>
        {(mic) => (mic ? <EndpointControls label="IN:" endpoint={mic} /> : <box />)}
      </With>

      <With value={createBinding(audio, "default-speaker")}>
        {(speaker) =>
          speaker ? <EndpointControls label="OUT:" endpoint={speaker} /> : <box />
        }
      </With>
    </box>
  );
}
