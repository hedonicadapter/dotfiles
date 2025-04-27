import { Variable, bind } from "astal";
import { Gtk } from "astal/gtk3";

const temperature = Variable(0).poll(
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
    <box className="bar-item temperature">
      <box
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        onDestroy={() => temperature.drop()}
        className={bind(temperature).as((t: number) => {
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
          label={bind(temperature).as((t) => t.toString() + "°")}
          className="temperature-label"
        />
        <icon
          className="fan"
          icon="fan-symbolic"
          valign={Gtk.Align.CENTER}
          halign={Gtk.Align.CENTER}
        />
      </box>
    </box>
  );
}
