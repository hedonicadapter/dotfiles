import Gtk from "gi://Gtk?version=3.0";
import { createPoll } from "ags/time";

const temperature = createPoll(
  0,
  5000,
  `bash -c '
      # AMD desktops expose CPU temp only via hwmon, not thermal zones
      for hw in /sys/class/hwmon/hwmon*; do
        case $(cat "$hw/name") in
          k10temp|zenpower)
            echo $(( $(cat "$hw/temp1_input") / 1000 ))
            exit 0
            ;;
        esac
      done

      max_temp=0
      for zone in /sys/class/thermal/thermal_zone*/temp; do
        temp=$(cat "$zone")
        if (( temp > max_temp )); then
          max_temp=$temp
        fi
      done
      echo $((max_temp / 1000))
  '`,
  (out) => Number(out.trim()) || 0,
);

export default function TemperatureComponent() {
  return (
    <box class="bar-item temperature">
      <box
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        class={temperature.as((t) => {
          switch (true) {
            case t < 40:
              return "low";
            case t < 70:
              return "mid";
            default:
              return "high";
          }
        })}
      >
        <label
          valign={Gtk.Align.CENTER}
          label={temperature.as((t) => t.toString() + "°")}
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
