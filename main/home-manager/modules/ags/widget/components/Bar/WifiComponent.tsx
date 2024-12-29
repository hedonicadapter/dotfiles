import { Gtk } from "astal/gtk3";
import { bind, Variable } from "astal";
import Network from "gi://AstalNetwork";

export default function WifiComponent() {
  const network = Network.get_default();

  return (
    <box className="bar-item indicator">
      <icon
        className="network "
        icon={bind(network, "wired").as((w) => {
          if (w.internet === 0) return "wired-connected-symbolic";
          else if (w.internet === 1) return "wired-connecting-symbolic";
          else if (w.internet === 2) return "wired-disconnected-symbolic";
          else return "UNKNOWN";
        })}
      />
    </box>
  );
}
