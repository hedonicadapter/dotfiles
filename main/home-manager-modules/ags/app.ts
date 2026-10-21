import app from "ags/gtk3/app";
import { createRoot } from "ags";
import Gdk from "gi://Gdk?version=3.0";
import Gtk from "gi://Gtk?version=3.0";
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
import { connect as connectKeyboardBattery } from "./keyboardBattery";

const style = await readFileAsync("style.scss");
const convertedToCss = await execAsync(
  `bash -c "echo '${style}' | sass --stdin"`,
);

app.start({
  css: convertedToCss,
  icons: `${SRC}/icons`,
  main() {
    connectNiri();
    connectKeyboardBattery();

    // Layer surfaces die with their output — rebuild per-monitor windows on hotplug
    const teardown = new Map<Gdk.Monitor, () => void>();
    let nextId = 0;
    const syncMonitors = () => {
      const monitors = app.get_monitors();

      for (const [monitor, dispose] of teardown) {
        if (monitors.includes(monitor)) continue;
        dispose();
        teardown.delete(monitor);
      }

      for (const monitor of monitors) {
        if (teardown.has(monitor)) continue;
        const id = nextId++;
        teardown.set(
          monitor,
          createRoot((dispose) => {
            const windows = [Bar, Dash, Outline].map(
              (create) => create(monitor, id) as Gtk.Window,
            );
            return () => {
              windows.forEach((win) => win.destroy());
              dispose();
            };
          }),
        );
      }
    };

    syncMonitors();
    app.connect("notify::monitors", syncMonitors);
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
