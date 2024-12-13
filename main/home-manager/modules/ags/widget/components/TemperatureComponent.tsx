import { Variable, bind } from "astal";

const temperature = Variable("").poll(
  1000,
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
    <label
      className={bind(temperature).as((t: string) => {
        let className = "temperature ";
        let num = parseInt(t);
        switch (true) {
          case num < 40:
            className += "low";
          case num < 70:
            className += "mid";
          case num >= 70:
            className += "high";
        }
        return className;
      })}
    >
      {bind(temperature).as((t: string) => `${t}󰔄`)}
    </label>
  );
}
