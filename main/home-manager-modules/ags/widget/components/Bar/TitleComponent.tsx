import Hyprland from "gi://AstalHyprland";
import Gtk from "gi://Gtk?version=3.0";
import { execAsync } from "ags/process";
import { escapeShellString } from "../../../util";
import { createState, createBinding } from "ags";

export default function TitleComponent() {
  const hypr = Hyprland.get_default();
  const focused = createBinding(hypr, "focusedClient");
  const [currentTitle, setCurrentTitle] = createState("");
  let timeout: ReturnType<typeof setTimeout>;

  const copyToClipboardAndNotify = async (title: string) => {
    try {
      const escapedString = escapeShellString(title);
      await execAsync(`bash -c "wl-copy '${escapedString}'"`);
      setCurrentTitle("COPIED.");
      clearTimeout(timeout);
      timeout = setTimeout(() => setCurrentTitle(title), 1000);
    } catch (e) {
      console.log("Error copying title: ", e);
    }
  };

  return (
    <box class="bar-item title" visible={focused} valign={Gtk.Align.CENTER}>
      {focused((client) => {
        const title =
          client.title.length > 0 ? client.title.split("—")[0] : "♥︎";
        clearTimeout(timeout);
        currentTitle.set(title);

        return (
          <eventbox onClick={() => copyToClipboardAndNotify(title)}>
            <label
              valign={Gtk.Align.CENTER}
              ellipsize={3}
              label={currentTitle((s) => s || "NULL")}
            />
          </eventbox>
        );
      })}
    </box>
  );
}
