import Gtk from "gi://Gtk?version=3.0";
import { splitBattery, type SplitBattery } from "../../../keyboardBattery";

const percent = (level: number | null) => (level === null ? "—" : `${level}%`);

// Colour by the emptier half
function levelClass({ left, right }: SplitBattery) {
  const levels = [left, right].filter((l): l is number => l !== null);
  if (!levels.length) return "main low";
  const lowest = Math.min(...levels);
  if (lowest <= 15) return "main high";
  if (lowest <= 30) return "main mid";
  return "main low";
}

export default function KeyboardBatteryComponent() {
  return (
    <box
      class="bar-item keyboard-battery"
      visible={splitBattery.as((b) => b.connected)}
      tooltipText={splitBattery.as((b) => b.name)}
    >
      <box class={splitBattery.as(levelClass)} valign={Gtk.Align.CENTER}>
        <label
          class="bar-label"
          label={splitBattery.as(
            (b) => `⌨ L ${percent(b.left)} R ${percent(b.right)}`,
          )}
        />
      </box>
    </box>
  );
}
