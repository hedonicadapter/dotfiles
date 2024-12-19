import { Gtk } from "astal/gtk3";
import { GLib, Variable } from "astal";

const time = Variable<string>("").poll(
  1000,
  () => GLib.DateTime.new_now_local().format("%a %d %b %H:%M")!,
);

export default function TimeComponent() {
  return (
    <label className="bar-item " onDestroy={() => time.drop()} label={time()} />
  );
}
