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

// CPU_FAN header (fan2) on Nuvoton NCT67xx boards; 0 when absent, e.g. laptop
const fanRpm = createPoll(
  0,
  5000,
  `bash -c '
      for hw in /sys/class/hwmon/hwmon*; do
        case $(cat "$hw/name") in
          nct67*)
            cat "$hw/fan2_input"
            exit 0
            ;;
        esac
      done
      echo 0
  '`,
  (out) => Number(out.trim()) || 0,
);

export default function TemperatureComponent() {
  return (
    <box
      class="bar-item temperature"
      tooltipText={fanRpm.as((r) => (r > 0 ? `${r} RPM` : ""))}
    >
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
          class={fanRpm.as((r) => {
            // Spin follows real RPM when known, else temperature (CSS)
            switch (true) {
              case r <= 0:
                return "fan";
              case r < 900:
                return "fan rpm-slow";
              case r < 1250:
                return "fan rpm-mid";
              default:
                return "fan rpm-fast";
            }
          })}
          icon="fan-symbolic"
          valign={Gtk.Align.CENTER}
          halign={Gtk.Align.CENTER}
        />
      </box>
    </box>
  );
}
