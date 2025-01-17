import { Gtk } from "astal/gtk3";
import { GLib, Variable } from "astal";

const time = Variable<string>("").poll(
  1000,
  () => GLib.DateTime.new_now_local().format("%a %d %b %H:%M")!,
);

export default function TimeComponent() {
  return (
    <label
      className="bar-item time"
      onDestroy={() => time.drop()}
      label={time()}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    />
  );
}
