import { Variable, bind } from "astal";

const temperature = Variable(0).poll(
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
      className={bind(temperature).as((t: number) => {
        let className = "temperature ";
        switch (true) {
          case t < 40:
            className += "low";
          case t < 70:
            className += "mid";
          case t >= 70:
            className += "high";
        }
        return className;
      })}
      label={bind(temperature).as((t) => t.toString() + "°")}
      onDestroy={() => temperature.drop()}
    />
  );
}
