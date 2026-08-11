import app from "ags/gtk3/app";
import Gtk from "gi://Gtk?version=3.0";
import Bar from "./widget/Bar";
import Outline from "./widget/Outline";
import Dash from "./widget/Dash";
import { readFile, readFileAsync } from "ags/file";
import { execAsync } from "ags/process";
import { toggleHAL } from "./widget/components/Dash/HALComponent";
import { toggleAudioSettings } from "./widget/components/Bar/AudioSettingsComponent";

const monitors = app.get_monitors();

const style = await readFileAsync("style.scss");
const convertedToCss = await execAsync(
  `bash -c "echo '${style}' | sass --stdin"`,
);

app.start({
  css: convertedToCss,
  icons: `${SRC}/icons`,
  // env: ".env",
  main() {
    monitors.map(Bar);
    monitors.map(Dash);
    monitors.map(Outline);
  },
  // TODO:
  // requestHandler(request: string[], res: (response: any) => void) {
  //   switch (request) {
  //     case "toggleHAL":
  //       toggleHAL.set(!toggleHAL.get());
  //       break;
  //     case "toggleAudioSettings":
  //       toggleAudioSettings.set(!toggleAudioSettings.get());
  //       break;
  //   }
  // },
});
