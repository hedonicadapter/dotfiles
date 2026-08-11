import Gtk from "gi://Gtk?version=3.0";
import { createState } from "ags";
import { subprocess, type Process } from "ags/process";

const noiseTypes = ["off", "brown", "pink", "white"];
const [noiseTypeSelectedIndex, setNoiseTypeSelectedIndex] = createState(0);
const [currentSubproc, setCurrentSubproc] = createState<Process | null>(null);

const stopNoise = () => currentSubproc.peek()?.kill();

const playNoise = () => {
  stopNoise();

  const noiseToPlay = noiseTypes[noiseTypeSelectedIndex.peek()];
  if (noiseToPlay === "off") return;

  const noisePlayer = subprocess(
    `bash -c 'mpv --no-audio-display --loop ~/.config/ags/noise/${noiseToPlay}.flac'`,
  );
  setCurrentSubproc(noisePlayer);
};

// Wrap on the last type — index === length left the label blank for one click
const cycleNoise = () =>
  setNoiseTypeSelectedIndex((i) => (i + 1) % noiseTypes.length);

noiseTypeSelectedIndex.subscribe(playNoise);

export default function () {
  return (
    <eventbox
      class="bar-item noise-player"
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
      onClick={() => cycleNoise()}
    >
      <label label={noiseTypeSelectedIndex.as((n) => noiseTypes[n])} />
    </eventbox>
  );
}
