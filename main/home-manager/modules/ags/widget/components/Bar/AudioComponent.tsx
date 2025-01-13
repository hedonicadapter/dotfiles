import { Variable, bind, type Binding } from "astal";
import { Gtk } from "astal/gtk3";
import Wp from "gi://AstalWp";
import Hoverable from "../Hoverable";

const { START, CENTER } = Gtk.Align;

const audio = Wp.get_default()?.audio;

const speaker = audio.defaultSpeaker!;
const mic = audio.defaultMicrophone!;

const UnmuteButton = ({ stream }: { stream: any }) => {
  return (
    <button onClicked={() => (stream.mute = false)}>
      <label label="MUTED" />
    </button>
  );
};

// const volOrMuted: (
//   n: Binding<number>,
//   b: Binding<boolean>,
// ) => Variable<string> = (n, b) =>
//   Variable.derive([n, b], (n: number, b: boolean) => {
//     if (b) return "MUTED ";
//     return bars(n);
//   });

const Bar = ({ stream }: { stream: any }) => {
  return (
    <box>
      {bind(stream, "volume").as((volume) =>
        Array.from({ length: 5 }).map((_, i) => {
          const tenths = Math.round(parseFloat(volume) * 5);
          const fill = i <= tenths;

          return (
            <button
              className="bar"
              onClicked={() => {
                const newVolume = i * 0.2;

                stream.volume = newVolume;
              }}
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
  const outputMuted: Binding<boolean> = bind(speaker, "mute");
  const inputMuted: Binding<boolean> = bind(mic, "mute");

  // const outputVolOrMuted = volOrMuted(output, outputMuted);
  // const inputVolOrMuted = volOrMuted(input, inputMuted);

  return (
    <Hoverable
      className="audio"
      main={
        <box className="main" valign={CENTER} halign={START}>
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
                <box />
              ),
            )}
            <Bar stream={mic} />
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
                <button
                  valign={CENTER}
                  onClicked={() => (speaker.mute = false)}
                >
                  <label valign={CENTER} label="MUTED" />
                </button>
              ) : (
                <box />
              ),
            )}
            <Bar stream={speaker} />
          </box>
        </box>
      }
      hoveredElement={
        <box className="panel" vertical>
          {bind(audio, "streams").as((streams) =>
            streams.length > 0 ? (
              streams.map((stream: any) => {
                return (
                  <box vertical>
                    <button
                      valign={START}
                      onClicked={() => (stream.mute = !stream.mute)}
                    >
                      <label
                        className="bar-label"
                        label={stream.name || ""}
                        halign={START}
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
      }
    />
  );
}
