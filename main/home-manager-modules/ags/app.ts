import { App } from "astal/gtk3";
import { Variable } from "astal";
import Bar from "./widget/Bar";
import Outline from "./widget/Outline";
import Dash from "./widget/Dash";
import { readFile, readFileAsync } from "astal/file";
import { execAsync } from "astal/process";
import { toggleHAL } from "./widget/components/Dash/HALComponent";
import { toggleAudioSettings } from "./widget/components/Bar/AudioSettingsComponent";

const monitors = App.get_monitors();

const style = await readFileAsync("style.scss");
const convertedToCss = await execAsync(
  `bash -c "echo '${style}' | sass --stdin"`,
);

App.start({
  css: convertedToCss,
  icons: `${SRC}/icons`,
  // env: ".env",
  main() {
    monitors.map(Bar);
    monitors.map(Dash);
    monitors.map(Outline);
  },
  requestHandler(request: string, res: (response: any) => void) {
    switch (request) {
      case "toggleHAL":
        toggleHAL.set(!toggleHAL.get());
        break;
      case "toggleAudioSettings":
        toggleAudioSettings.set(!toggleAudioSettings.get());
        break;
    }
  },
});
