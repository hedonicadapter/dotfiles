import { Gtk } from "astal/gtk3";
import { bind, Variable } from "astal";
import Network from "gi://AstalNetwork";

const connectivityEnumToIcon = {
  [Network.Connectivity.UNKNOWN]: "unknown",
  [Network.Connectivity.NONE]: "none",
  [Network.Connectivity.PORTAL]: "portal",
  [Network.Connectivity.LIMITED]: "limited",
  [Network.Connectivity.FULL]: "full",
};

const wiredEnumToIcon = {
  [Network.DeviceState.UNKNOWN]: "unknown",
  [Network.DeviceState.UNMANAGED]: "unmanaged",
  [Network.DeviceState.UNAVAILABLE]: "unavailable",
  [Network.DeviceState.DISCONNECTED]: "disconnected",
  [Network.DeviceState.PREPARE]: "prepare",
  [Network.DeviceState.CONFIG]: "config",
  [Network.DeviceState.NEED_AUTH]: "need_auth",
  [Network.DeviceState.IP_CONFIG]: "ip_config",
  [Network.DeviceState.IP_CHECK]: "ip_check",
  [Network.DeviceState.SECONDARIES]: "secondaries",
  [Network.DeviceState.ACTIVATED]: "activated",
  [Network.DeviceState.DEACTIVATING]: "deactivating",
  [Network.DeviceState.FAILED]: "failed",
};
const wifiEnumToIcon = {
  [Network.State.UNKNOWN]: "unknown",
  [Network.State.ASLEEP]: "asleep",
  [Network.State.DISCONNECTED]: "disconnected",
  [Network.State.DISCONNECTING]: "disconnecting",
  [Network.State.CONNECTING]: "connecting",
  [Network.State.CONNECTED_LOCAL]: "connected-local",
  [Network.State.CONNECTED_SITE]: "connected-site",
  [Network.State.CONNECTED_GLOBAL]: "connected-global",
};

export default function WifiComponent() {
  const network = Network.get_default();

  const state = bind(network, "state");
  const connectivity = bind(network, "connectivity");
  const wired = bind(network, "wired");
  const wifi = bind(network, "wifi");

  const networking = Variable.derive(
    [state, connectivity, wired, wifi],
    (state: any, connectivity: any, wired: any, wifi: any) => {
      // const conn = connectivityEnumToIcon[connectivity];
      // const st = connectivityEnumToIcon[state];
      // const wir = connectivityEnumToIcon[wired];
      // const wif = connectivityEnumToIcon[wifi];
      // console.log(state);
      // console.log(st);
      //
      // // presedence:
      // if (connectedStates.includes(state)) {
      //   //    Connected: connectivity > wired > wifi > state
      //   return "connectivity-" + (conn || wir || wif || st || "unknown");
      // } else {
      //   //    Not Connected: state > connectivity > wired > wifi
      //   return "state-" + (st || conn || wir || wif || "unknown");
      // }
      return "NOT IMPLEMENTED";
    },
  );

  return (
    <box
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
      className="bar-item network"
      onDestroy={() => networking.drop()}
    >
      <icon
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        icon={bind(networking)}
      />
      <label
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        label={bind(networking).as((s) => s.replaceAll("-", " ").toUpperCase())}
      />
    </box>
  );
}
