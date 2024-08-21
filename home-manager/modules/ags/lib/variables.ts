import GLib from "gi://GLib";
// import options from "options";

// const intval = options.system.fetchInterval.value;

export const clock = Variable(GLib.DateTime.new_now_local(), {
  poll: [1000, () => GLib.DateTime.new_now_local()],
});

export const zenable = Variable(false);
export const toggleZenable = () => zenable.setValue(!zenable.value);

export const uptime = Variable(0, {
  poll: [
    60_000,
    "cat /proc/uptime",
    (line) => Number.parseInt(line.split(".")[0]) / 60,
  ],
});

export const temperature = Variable(0, {
  poll: [
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
  ],
});
