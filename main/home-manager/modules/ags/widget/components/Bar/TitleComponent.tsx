import Hyprland from "gi://AstalHyprland";
import { Gtk } from "astal/gtk3";
import { bind } from "astal";

export default function TitleComponent() {
  const hypr = Hyprland.get_default();
  const focused = bind(hypr, "focusedClient");

  return (
    <box
      className="bar-item title"
      visible={focused.as(Boolean)}
      valign={Gtk.Align.CENTER}
    >
      {focused.as(
        (client) =>
          client && (
            <label
              valign={Gtk.Align.CENTER}
              ellipsize={3}
              label={bind(client, "title").as(String)}
            />
          ),
      )}
    </box>
  );
}
