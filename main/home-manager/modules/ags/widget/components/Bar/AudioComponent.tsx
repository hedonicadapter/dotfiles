import { Variable, bind, type Binding } from "astal";
import { Gtk } from "astal/gtk3";
import Wp from "gi://AstalWp";
import { execAsync } from "astal/process";

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
        Array.from({ length: 10 }).map((_, i) => {
          const tenths = Math.round(parseFloat(volume) * 10);
          const fill = i <= tenths;

          return (
            <button
              onClicked={() => {
                const newVolume = i * 0.1;

                stream.volume = newVolume;
              }}
            >
              <label halign={START} label={fill ? "▮" : "▯"} />
            </button>
          );
        }),
      )}
    </box>
  );
};

export default function () {
  const hovered = Variable(false);

  const outputMuted: Binding<boolean> = bind(speaker, "mute");
  const inputMuted: Binding<boolean> = bind(mic, "mute");

  // const outputVolOrMuted = volOrMuted(output, outputMuted);
  // const inputVolOrMuted = volOrMuted(input, inputMuted);

  return (
    <eventbox
      className={bind(hovered).as((h) =>
        h ? "bar-item audio hovered" : "bar-item audio",
      )}
      onHover={() => hovered.set(true)}
      onHoverLost={() => hovered.set(false)}
      onDestroy={() => {
        hovered.drop();
      }}
      valign={CENTER}
    >
      <box valign={CENTER} vertical>
        <box className="default-io" valign={CENTER}>
          <box valign={CENTER}>
            <button onClicked={() => (mic.mute = !mic.mute)}>
              <label className="bar-label" label="IN:" />
            </button>

            {bind(mic, "muted").as((m) =>
              m ? (
                <button onClicked={() => (mic.mute = false)}>
                  <label label="MUTED" />
                </button>
              ) : (
                <box />
              ),
            )}
            <Bar stream={mic} />
          </box>

          <box valign={CENTER}>
            <button onClicked={() => (speaker.mute = !speaker.mute)}>
              <label className="bar-label" label="OUT:" />
            </button>

            {bind(speaker, "muted").as((m) =>
              m ? (
                <button onClicked={() => (speaker.mute = false)}>
                  <label label="MUTED" />
                </button>
              ) : (
                <box />
              ),
            )}
            <Bar stream={speaker} />
          </box>
        </box>
        <box className="panel" visible={bind(hovered)} vertical>
          {bind(audio, "streams").as((streams) =>
            streams.length > 0 ? (
              streams.map((stream: any) => {
                return (
                  <box vertical>
                    <button onClicked={() => (stream.mute = !stream.mute)}>
                      <label className="bar-label" label={stream.name || ""} />
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
    </eventbox>
  );
}
