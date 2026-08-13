import Gtk from "gi://Gtk?version=3.0";
import { createBinding, createState, For, With } from "ags";
import Wp, { type Endpoint } from "gi://AstalWp";
import { Bar } from "./AudioComponent";

const { START, CENTER, END } = Gtk.Align;

export const [toggleAudioSettings, setAudioSettings] = createState(false);

const DevicePanel = ({ io }: { io: "input" | "output" }) => {
  const audio = Wp.get_default()?.audio;
  if (!audio) return <box />;

  // Follows the default device instead of capturing whichever was default
  // when the widget was built
  const defaultEndpoint = createBinding(
    audio,
    io === "input" ? "default-microphone" : "default-speaker",
  );

  return (
    <box vertical>
      <box>
        <label
          halign={START}
          valign={CENTER}
          class="heading"
          label={io.toUpperCase()}
          maxWidthChars={50}
          ellipsize={3}
          truncate
          hexpand
        />
        <box halign={END} valign={CENTER}>
          <With value={defaultEndpoint}>
            {(endpoint) => (endpoint ? <Bar stream={endpoint} /> : <box />)}
          </With>
        </box>
      </box>

      <box vertical>
        <For each={createBinding(audio, io === "input" ? "microphones" : "speakers")}>
          {(s: Endpoint) => (
            <button
              class={createBinding(s, "isDefault").as((b) => (b ? "active" : ""))}
              onClicked={() => s.set_is_default(true)}
              valign={CENTER}
              hexpand
            >
              <label
                valign={CENTER}
                halign={START}
                class="bar-label"
                label={s.description || ""}
              />
            </button>
          )}
        </For>
      </box>
    </box>
  );
};

export default function AudioSettingsComponent() {
  const audio = Wp.get_default()?.audio;

  return (
    <box
      class="audio-settings"
      visible={toggleAudioSettings}
      halign={START}
      vexpand
      vertical
    >
      <box class="panel device-panel" hexpand>
        <DevicePanel io="input" />
      </box>

      <box class="panel device-panel" hexpand>
        <DevicePanel io="output" />
      </box>

      <box class="panel endpoints" orientation={1} vertical={true}>
        <label class="heading" halign={START} valign={CENTER} label="MIXER" />

        {audio && (
          <For each={createBinding(audio, "streams")}>
            {(stream: any) => (
              <box hexpand>
                <button
                  valign={START}
                  class={createBinding(stream, "mute").as((b) =>
                    b ? "muted" : "",
                  )}
                  onClicked={() => (stream.mute = !stream.mute)}
                  hexpand
                >
                  <label
                    label={stream.name || ""}
                    halign={START}
                    ellipsize={3}
                  />
                </button>

                <Bar stream={stream} />
              </box>
            )}
          </For>
        )}
      </box>
    </box>
  );
}
