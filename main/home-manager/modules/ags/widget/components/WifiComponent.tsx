import { bind } from "astal";
import Network from "gi://AstalNetwork";

export default function WifiComponent() {
  const { wifi } = Network.get_default();

  return (
    <icon
      tooltipText={bind(wifi, "ssid").as(String)}
      className="wifi indicator"
      icon={bind(wifi, "iconName")}
    />
  );
}
