import Gtk from "gi://Gtk?version=3.0";
import { createState, With } from "ags";
import { execAsync } from "ags/process";
import { escapeShellString } from "../../../util";
import { focusedWindow } from "../../../niri";

export default function TitleComponent() {
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
    <box
      class="bar-item title"
      visible={focusedWindow.as(Boolean)}
      valign={Gtk.Align.CENTER}
    >
      <With value={focusedWindow}>
        {(client) => {
          const title = client?.title?.length
            ? client.title.split("—")[0]
            : "♥︎";
          clearTimeout(timeout);
          setCurrentTitle(title);

          return (
            <eventbox onClick={() => copyToClipboardAndNotify(title)}>
              <label
                valign={Gtk.Align.CENTER}
                ellipsize={3}
                label={currentTitle}
              />
            </eventbox>
          );
        }}
      </With>
    </box>
  );
}
