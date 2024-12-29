import { Variable, bind, type Binding } from "astal";
import { Gtk } from "astal/gtk3";
import Wp from "gi://AstalWp";
import { execAsync } from "astal/process";

const { START, CENTER } = Gtk.Align;

const audio = Wp.get_default()?.audio;

const speaker = audio.defaultSpeaker!;
const mic = audio.defaultMicrophone!;

const VolumeButton = ({ stream, index }: { stream: any; index: number }) => {
  const tenths = parseInt((stream.volume, 10).toFixed(0), 10);

  return (
    <button
      onClicked={async () => {
        const newVolume = index * 0.1;

        await execAsync(
          `bash -c "wpctl set-volume  ${stream.id} ${newVolume}"`,
        );
      }}
    >
      <label halign={START} label={index <= tenths ? "▮" : "▯"} />
    </button>
  );
};

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

export default function () {
  const hovered = Variable(false);

  const output: Binding<number> = bind(speaker, "volume");
  const outputMuted: Binding<boolean> = bind(speaker, "mute");
  const input: Binding<number> = bind(mic, "volume");
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
        // outputVolOrMuted.drop();
        // inputVolOrMuted.drop();
        hovered.drop();
      }}
      valign={CENTER}
    >
      <box valign={CENTER} vertical>
        <box className="default-io" valign={CENTER}>
          {bind(audio, "defaultMicrophone").as((s) => (
            <box valign={CENTER}>
              <button onClicked={() => (s.mute = !s.mute)}>
                <label className="bar-label" label="IN:" />
              </button>
              <box>
                {bind(outputMuted).as((b) =>
                  b ? (
                    <UnmuteButton stream={s} />
                  ) : (
                    Array.from({ length: 10 }).map((_, i) => (
                      <VolumeButton stream={s} index={i} />
                    ))
                  ),
                )}
              </box>
            </box>
          ))}
          {bind(audio, "defaultSpeaker").as((s) => (
            <box valign={CENTER}>
              <button onClicked={() => (s.mute = !s.mute)}>
                <label className="bar-label" label="OUT:" />
              </button>
              <box>
                {bind(outputMuted).as((b) =>
                  b ? (
                    <UnmuteButton stream={s} />
                  ) : (
                    Array.from({ length: 10 }).map((_, i) => (
                      <VolumeButton stream={s} index={i} />
                    ))
                  ),
                )}
              </box>
            </box>
          ))}
        </box>
        <box className="panel" visible={bind(hovered)} vertical>
          {bind(audio, "streams").as(
            (streams) =>
              streams.length > 0 &&
              streams.map((stream: any) => {
                return (
                  <box vertical>
                    <label halign={START} label={stream.name || ""} />

                    <box>
                      {stream.mute ? (
                        <UnmuteButton stream={stream} />
                      ) : (
                        Array.from({ length: 10 }).map((_, i) => (
                          <VolumeButton stream={stream} index={i} />
                        ))
                      )}
                    </box>
                  </box>
                );
              }),
          )}
        </box>
      </box>
    </eventbox>
  );
}
