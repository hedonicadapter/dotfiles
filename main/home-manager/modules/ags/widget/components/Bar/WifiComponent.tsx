import { Gtk } from "astal/gtk3";
import { bind, Variable } from "astal";
import Network from "gi://AstalNetwork";

const wifiNone = "⌔";
const wifiLow = "";
const wifiMid = "";
const wifiHigh = "";

const wiredNone = "";
const wiredLow = "";
const wiredMid = "";
const wiredHigh = "";

export default function WifiComponent() {
  const { wifi, wired } = Network.get_default();
  let interval: null | ReturnType<typeof setInterval> = null;

  return (
    <label
      tooltipText={bind(wifi, "ssid").as(String)}
      className="bar-item network indicator"
      setup={(self) => {
        interval = setInterval(() => {
          const { wifi, wired } = Network.get_default();

          const { enabled, strength, ssid, internet: wifiConnStatus } = wifi;
          const { speed, internet: wiredConnStatus } = wired;
          // console.log({ speed });
          // console.log({ strength });

          // self.label =
        }, 1000);
      }}
      onDestroy={() => interval && clearInterval(interval)}
    />
  );
}
