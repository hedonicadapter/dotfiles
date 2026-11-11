import Gtk from "gi://Gtk?version=3.0";
import Wp from "gi://AstalWp";
import { createBinding, createComputed, createState } from "ags";
import { createPoll } from "ags/time";
import { screencasting } from "../../../compositor";

const audio = Wp.get_default()?.audio ?? null;
const [noRecorders] = createState<Wp.Stream[]>([]);

// pavucontrol's level meters open capture streams without recording anything
const IGNORED = /peak detect/i;

const DOTS = ["", ".", "..", "..."];
const dots = createPoll(0, 450, (i: number) => (i + 1) % DOTS.length);

export default function RecordingComponent() {
  // Who is capturing: mic streams by app, plus the screen
  const sources = createComputed(
    [audio ? createBinding(audio, "recorders") : noRecorders, screencasting],
    (recorders: Wp.Stream[], cast: boolean) => [
      ...(recorders ?? [])
        .map((r) => r.description || r.name || "AUDIO")
        .filter((name) => !IGNORED.test(name)),
      ...(cast ? ["SCREEN"] : []),
    ],
  );

  return (
    <box
      class="bar-item recording"
      visible={sources.as((s) => s.length > 0)}
      tooltipText={sources.as((s) => s.join(", ").toUpperCase())}
      valign={Gtk.Align.CENTER}
    >
      <box class="main" valign={Gtk.Align.CENTER}>
        {/* Padded so the dots don't shift the bar */}
        <label
          valign={Gtk.Align.CENTER}
          label={dots.as((i) => `RECORDING${DOTS[i].padEnd(3, " ")}`)}
        />
      </box>
    </box>
  );
}
