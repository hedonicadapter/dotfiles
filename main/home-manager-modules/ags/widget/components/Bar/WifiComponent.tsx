import Gtk from "gi://Gtk?version=3.0";
import { createBinding, createComputed } from "ags";
import Network from "gi://AstalNetwork";

const { Internet, Connectivity, Primary } = Network;

const wiredIcons = {
  [Internet.CONNECTED]: "wired-connected-symbolic",
  [Internet.CONNECTING]: "wired-connecting-symbolic",
  [Internet.DISCONNECTED]: "wired-disconnected-symbolic",
};

// Shown instead of the link name when NetworkManager can't reach the internet
const connectivityLabels: Partial<Record<Network.Connectivity, string>> = {
  [Connectivity.NONE]: "NO INTERNET",
  [Connectivity.PORTAL]: "LOGIN REQUIRED",
  [Connectivity.LIMITED]: "LIMITED",
};

export default function WifiComponent() {
  const network = Network.get_default();

  const status = createComputed(
    [
      createBinding(network, "primary"),
      createBinding(network, "connectivity"),
      createBinding(network, "wired", "internet"),
      createBinding(network, "wifi", "internet"),
      createBinding(network, "wifi", "iconName"),
    ],
    (primary, connectivity, wiredInternet, wifiInternet, wifiIcon) => {
      const useWifi =
        primary === Primary.WIFI ||
        (primary !== Primary.WIRED && wifiInternet === Internet.CONNECTED);

      if (useWifi && wifiInternet !== null) {
        if (wifiInternet === Internet.CONNECTING)
          return { icon: wifiIcon ?? "", label: "CONNECTING" };
        if (wifiInternet === Internet.CONNECTED)
          return {
            icon: wifiIcon ?? "",
            label: connectivityLabels[connectivity] ?? "WIFI",
          };
      }

      if (wiredInternet === Internet.CONNECTED)
        return {
          icon: wiredIcons[Internet.CONNECTED],
          label: connectivityLabels[connectivity] ?? "WIRED",
        };
      if (wiredInternet === Internet.CONNECTING)
        return { icon: wiredIcons[Internet.CONNECTING], label: "CONNECTING" };

      return { icon: wiredIcons[Internet.DISCONNECTED], label: "OFFLINE" };
    },
  );

  return (
    <box class="bar-item network">
      <box class="main" halign={Gtk.Align.START} valign={Gtk.Align.CENTER}>
        <icon
          class="spaced-icon"
          valign={Gtk.Align.CENTER}
          icon={status.as((s) => s.icon)}
        />
        <label valign={Gtk.Align.CENTER} label={status.as((s) => s.label)} />
      </box>
    </box>
  );
}
