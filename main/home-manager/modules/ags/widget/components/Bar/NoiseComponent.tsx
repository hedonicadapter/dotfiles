import { App, Gtk } from "astal/gtk3";
import { bind, Variable } from "astal";
import { subprocess, Process } from "astal/process";

const noiseTypes = ["off", "brown", "pink", "white"];
const noiseTypeSelectedIndex = Variable(0);
const currentSubproc = Variable<Process | null>(null);

const stopNoise = () => currentSubproc.get()?.kill();

const playNoise = () => {
  stopNoise();

  const noiseToPlay = noiseTypes[noiseTypeSelectedIndex.get()];
  if (noiseToPlay === "off") return;

  const noisePlayer = subprocess([
    "bash -c",
    `mpv --no-audio-display --loop ~/.config/ags/noise/${noiseTypes[noiseTypeSelectedIndex.get()]}.flac`,
  ]);
  currentSubproc.set(noisePlayer);
};

const cycleNoise = () => {
  const currentIndex = noiseTypeSelectedIndex.get();
  const max = noiseTypes.length;

  if (currentIndex + 1 > max) noiseTypeSelectedIndex.set(0);
  else noiseTypeSelectedIndex.set(currentIndex + 1);
};

noiseTypeSelectedIndex.subscribe(playNoise);

export default function () {
  return (
    <eventbox
      className="bar-item noise-player"
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
      onClick={() => cycleNoise()}
    >
      <label label={bind(noiseTypeSelectedIndex).as((n) => noiseTypes[n])} />
    </eventbox>
  );
}
