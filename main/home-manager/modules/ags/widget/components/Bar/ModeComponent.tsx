import { bind, Variable } from "astal";
import Hyprland from "gi://AstalHyprland";

export default function () {
  const hypr = Hyprland.get_default();
  const submapLabel = Variable("NORMAL");

  hypr.connect("submap", (_, submap) => {
    submap ? submapLabel.set(submap.toUpperCase()) : submapLabel.set("NORMAL");
  });

  return (
    <box className="bar-item mode">
      <label label={bind(submapLabel)} />
    </box>
  );
}
