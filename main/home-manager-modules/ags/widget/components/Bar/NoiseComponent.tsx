import Gtk from "gi://Gtk?version=3.0";
import { subprocess, Process } from "ags/process";
import { createState, createBinding } from "ags";

const noiseTypes = ["off", "brown", "pink", "white"];
const [noiseTypeSelectedIndex, setNoiseTypeSelectedIndex] = createState(0);
const currentSubproc = createState<Process | null>(null);

const stopNoise = () => currentSubproc?.kill();

const playNoise = () => {
  stopNoise();

  const noiseToPlay = noiseTypes[noiseTypeSelectedIndex];
  if (noiseToPlay === "off") return;

  const noisePlayer = subprocess(
    `bash -c 'mpv --no-audio-display --loop ~/.config/ags/noise/${noiseTypes[noiseTypeSelectedIndex]}.flac'`,
  );
  setCurrentSubproc(noisePlayer);
};

const max = noiseTypes.length;
const cycleNoise = () => {
  const currentIndex = noiseTypeSelectedIndex;

  if (currentIndex + 1 > max) setNoiseTypeSelectedIndex(0);
  else setNoiseTypeSelectedIndex(currentIndex + 1);
};

noiseTypeSelectedIndex.subscribe(playNoise);

export default function () {
  return (
    <eventbox
      class="bar-item noise-player"
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
      onClick={() => cycleNoise()}
    >
      <label label={noiseTypeSelectedIndex((n) => noiseTypes[n])} />
    </eventbox>
  );
}
