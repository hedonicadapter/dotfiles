import { Gtk } from "astal/gtk3";
import { bind } from "astal";
import Network from "gi://AstalNetwork";

export default function WifiComponent() {
  const { wifi } = Network.get_default();

  return (
    <icon
      tooltipText={bind(wifi, "ssid").as(String)}
      className="bar-item wifi indicator"
      icon={bind(wifi, "iconName")}
    />
  );
}
