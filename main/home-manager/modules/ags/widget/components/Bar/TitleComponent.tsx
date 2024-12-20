import Hyprland from "gi://AstalHyprland";
import { bind } from "astal";

export default function TitleComponent() {
  const hypr = Hyprland.get_default();
  const focused = bind(hypr, "focusedClient");

  return (
    <box className="bar-item " visible={focused.as(Boolean)}>
      {focused.as(
        (client) =>
          client && (
            <label
              ellipsize={3}
              label={">" + bind(client, "title").as(String)}
            />
          ),
      )}
    </box>
  );
}
