import Gtk from "gi://Gtk?version=3.0";
import { createPoll, createBinding } from "ags";

const temperature = createPoll(
  0,
  5000,
  `bash -c '
      max_temp=0
      for zone in /sys/class/thermal/thermal_zone*/temp; do
        temp=$(cat "$zone")
        if (( temp > max_temp )); then
          max_temp=$temp
        fi
      done
      echo $((max_temp / 1000))
  '`,
);

export default function TemperatureComponent() {
  return (
    <box class="bar-item temperature">
      <box
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        onDestroy={() => temperature.drop()}
        class={temperature((t: number) => {
          switch (true) {
            case t < 40:
              return "low";
            case t < 70:
              return "mid";
            case t >= 70:
              return "high";
          }
        })}
      >
        <label
          valign={Gtk.Align.CENTER}
          label={temperature((t) => t.toString() + "°")}
          class="temperature-label"
        />
        <icon
          class="fan"
          icon="fan-symbolic"
          valign={Gtk.Align.CENTER}
          halign={Gtk.Align.CENTER}
        />
      </box>
    </box>
  );
}
