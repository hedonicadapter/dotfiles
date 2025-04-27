import { Gtk } from "astal/gtk3";
import { GLib, Variable } from "astal";

const day = Variable<string>("").poll(
  1000,
  () => GLib.DateTime.new_now_local().format("%a %d %b")!,
);

const time = Variable<string>("").poll(
  1000,
  () => GLib.DateTime.new_now_local().format("%H:%M")!,
);

export default function TimeComponent() {
  return (
    <box
      className="bar-item datetime"
      onDestroy={() => {
        day.drop();
        time.drop();
      }}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <label
        label={day()}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
        className="day"
      />
      <label
        label={time()}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
        className="time"
      />
    </box>
  );
}
