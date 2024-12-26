import { Variable, bind, type Binding } from "astal";
import { Gtk } from "astal/gtk3";
import Wp from "gi://AstalWp";

const { START, CENTER } = Gtk.Align;

const bars = (n: number) => {
  const tenths = parseInt((n * 10).toFixed(0), 10);

  const indicator = Array.from({ length: 10 })
    .map((_, i) => (i + 1 <= tenths ? "▮" : "▯"))
    .join("");
  return indicator;
};

const volOrMuted: (
  n: Binding<number>,
  b: Binding<boolean>,
) => Variable<string> = (n, b) =>
  Variable.derive([n, b], (n: number, b: boolean) => {
    if (b) return "MUTED ";
    return bars(n);
  });

export default function () {
  const hovered = Variable(false);
  const audio = Wp.get_default()?.audio;

  const speaker = audio.defaultSpeaker!;
  const mic = audio.defaultMicrophone!;

  const output: Binding<number> = bind(speaker, "volume");
  const outputMuted: Binding<boolean> = bind(speaker, "mute");
  const input: Binding<number> = bind(mic, "volume");
  const inputMuted: Binding<boolean> = bind(mic, "mute");

  const outputVolOrMuted = volOrMuted(output, outputMuted);
  const inputVolOrMuted = volOrMuted(input, inputMuted);

  return (
    <eventbox
      className={bind(hovered).as((h) =>
        h ? "bar-item audio hovered" : "bar-item audio",
      )}
      onHover={() => hovered.set(true)}
      onHoverLost={() => hovered.set(false)}
      onDestroy={() => {
        outputVolOrMuted.drop();
        inputVolOrMuted.drop();
        hovered.drop();
      }}
      valign={CENTER}
    >
      <box valign={CENTER} vertical>
        <box className="default-io" valign={CENTER}>
          <box
            className={bind(outputMuted).as((b) => (b ? "muted" : ""))}
            valign={CENTER}
          >
            <label className="bar-label" label="OUT:" />
            <label
              className={bind(outputMuted).as((b) => (b ? "" : "bar"))}
              label={bind(outputVolOrMuted)}
            />
          </box>
          <box
            className={bind(outputMuted).as((b) => (b ? "muted" : ""))}
            valign={CENTER}
          >
            <label className="bar-label" label="IN:" />
            <label
              className={bind(inputMuted).as((b) => (b ? "" : "bar"))}
              label={bind(inputVolOrMuted)}
            />
          </box>
        </box>
        <box className="panel" visible={bind(hovered)} vertical>
          {bind(audio, "streams").as(
            (streams) =>
              streams.length > 0 &&
              streams.map((stream: any) => {
                return (
                  <box vertical>
                    <label halign={START} label={stream.name || ""} />

                    <label
                      className={stream.mute ? "" : "bar"}
                      label={bars(stream.volume, stream.mute)}
                    />
                  </box>
                );
              }),
          )}
        </box>
      </box>
    </eventbox>
  );
}
