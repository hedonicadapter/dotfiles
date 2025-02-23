import Hyprland from "gi://AstalHyprland";
import { Gtk } from "astal/gtk3";
import { bind, Variable } from "astal";
import { execAsync } from "astal/process";
import { escapeShellString } from "../../../util";

export default function TitleComponent() {
  const hypr = Hyprland.get_default();
  const focused = bind(hypr, "focusedClient");
  const currentTitle = Variable("");
  let timeout: ReturnType<typeof setTimeout>;

  const copyToClipboardAndNotify = async (title: string) => {
    try {
      const escapedString = escapeShellString(title);
      await execAsync(`bash -c "wl-copy '${escapedString}'"`);
      currentTitle.set("COPIED.");
      clearTimeout(timeout);
      timeout = setTimeout(() => currentTitle.set(title), 1000);
    } catch (e) {
      console.log("Error copying title: ", e);
    }
  };

  return (
    <box
      className="bar-item title"
      visible={focused.as(Boolean)}
      valign={Gtk.Align.CENTER}
    >
      {focused.as((client) => {
        const title =
          client.title.length > 0 ? client.title.split("—")[0] : "♥︎";
        clearTimeout(timeout);
        currentTitle.set(title);

        return (
          <eventbox onClick={() => copyToClipboardAndNotify(title)}>
            <label
              valign={Gtk.Align.CENTER}
              ellipsize={3}
              label={bind(currentTitle).as((s) => s || "NULL")}
            />
          </eventbox>
        );
      })}
    </box>
  );
}
