import GObject from "gi://GObject";
import { Gtk, Gdk } from "astal/gtk3";

const ignoreKeys = [
  Gdk.KEY_Alt_L,
  Gdk.KEY_Alt_R,
  Gdk.KEY_Shift_L,
  Gdk.KEY_Shift_R,
  Gdk.KEY_Meta_L,
  Gdk.KEY_Meta_R,
  Gdk.KEY_Control_L,
  Gdk.KEY_Control_R,
];

export default function ({
  onEnter,
  className,
}: {
  onEnter: (currentText: string) => void;
  className?: string;
}) {
  const textBuffer = new Gtk.TextBuffer();
  const textView = new Gtk.TextView({ buffer: textBuffer });
  textView.visible = true;
  textView.hexpand = true;

  return (
    <eventbox
      onKeyPressEvent={(_: Gtk.EventBox, evt: Gdk.Event) => {
        console.log(evt.get_keyval()[1]);
        if (ignoreKeys.includes(evt.get_keyval()[1])) return;

        const bounds = textBuffer.get_bounds();
        const currentText = textBuffer
          .get_text(bounds[0], bounds[1], true)
          ?.trim();
        if (!currentText) return;

        onEnter(currentText);
        textBuffer.set_text("", 0);
      }}
    >
      <box className={className}>{textView}</box>
    </eventbox>
  );
}
