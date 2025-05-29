import { Gtk } from "astal/gtk3";
import { Variable, bind, type Binding } from "astal";
import Wp, { type Device, type Endpoint, type Stream } from "gi://AstalWp";
import { Bar } from "./AudioComponent";

const { START, CENTER, END } = Gtk.Align;

export const toggleAudioSettings = Variable(false);

const DevicePanel = ({ io }: { io: "input" | "output" }) => {
  const wp = Wp.get_default();
  const audio = wp?.audio;

  const binding =
    io === "input" ? audio.default_microphone : audio.default_speaker;

  return (
    <box vertical>
      <box>
        <label
          halign={START}
          valign={CENTER}
          className="heading"
          label={io.toUpperCase()}
          maxWidthChars={50}
          ellipsize={3}
          truncate
          hexpand
        />
        <box halign={END} valign={CENTER}>
          <Bar stream={binding} />
        </box>
      </box>

      <box vertical>
        {bind(audio, io === "input" ? "microphones" : "speakers").as(
          (ss: Endpoint[]) =>
            ss.map((s: Endpoint) => (
              <button
                className={bind(s, "isDefault").as((b) => (b ? "active" : ""))}
                onClicked={() => s.set_is_default(true)}
                valign={CENTER}
                hexpand
              >
                <label
                  valign={CENTER}
                  halign={START}
                  className="bar-label"
                  label={s.description || ""}
                />
              </button>
            )),
        )}
      </box>
    </box>
  );
};

export default function () {
  const wp = Wp.get_default();
  const audio = wp?.audio;

  return (
    <box
      className="audio-settings"
      visible={bind(toggleAudioSettings)}
      halign={START}
      vexpand
      vertical
    >
      <box className="panel device-panel" hexpand>
        <DevicePanel io="input" />
      </box>

      <box className="panel device-panel" hexpand>
        <DevicePanel io="output" />
      </box>

      <box className="panel endpoints" orientation={1} vertical={true}>
        <label
          className="heading"
          halign={START}
          valign={CENTER}
          label="MIXER"
        />

        {bind(audio, "streams").as((streams) =>
          streams.length > 0 ? (
            streams.map((stream: any) => {
              return (
                <box hexpand>
                  <button
                    valign={START}
                    className={bind(stream, "mute").as((b) =>
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
              );
            })
          ) : (
            <box />
          ),
        )}
      </box>
    </box>
  );
}
