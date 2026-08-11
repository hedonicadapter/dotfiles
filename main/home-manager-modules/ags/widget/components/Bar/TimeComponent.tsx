import Gtk from "gi://Gtk?version=3.0";
import GLib from "gi://GLib";
import { createPoll } from "ags/time";

const day = createPoll("", 1000, () =>
  GLib.DateTime.new_now_local().format("%a %d %b")!,
);

const time = createPoll("", 1000, () =>
  GLib.DateTime.new_now_local().format("%H:%M")!,
);

export default function TimeComponent() {
  return (
    <box
      class="bar-item datetime"
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
    >
      <label
        label={day}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
        class="day"
      />
      <label
        label={time}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
        class="time"
      />
    </box>
  );
}
