import app from "ags/gtk3/app";
import Bar from "./widget/Bar";
import Outline from "./widget/Outline";
import Dash from "./widget/Dash";
import { readFileAsync } from "ags/file";
import { execAsync } from "ags/process";
import { setHAL, toggleHAL } from "./widget/components/Dash/HALComponent";
import {
  setAudioSettings,
  toggleAudioSettings,
} from "./widget/components/Bar/AudioSettingsComponent";
import { connect as connectNiri } from "./niri";

const style = await readFileAsync("style.scss");
const convertedToCss = await execAsync(
  `bash -c "echo '${style}' | sass --stdin"`,
);

app.start({
  css: convertedToCss,
  icons: `${SRC}/icons`,
  main() {
    connectNiri();

    const monitors = app.get_monitors();
    monitors.map(Bar);
    monitors.map(Dash);
    monitors.map(Outline);
  },
  requestHandler(argv: string[], res: (response: any) => void) {
    switch (argv[0]) {
      case "toggleHAL":
        setHAL(!toggleHAL.peek());
        break;
      case "toggleAudioSettings":
        setAudioSettings(!toggleAudioSettings.peek());
        break;
    }
    res("ok");
  },
});
