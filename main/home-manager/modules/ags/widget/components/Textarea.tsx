import GObject from "gi://GObject";
import { Gtk, Gdk } from "astal/gtk3";

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
        // if (evt.get_keyval()[1] === Gdk.KEY_KP_Enter) {
        const bounds = textBuffer.get_bounds();
        const currentText = textBuffer
          .get_text(bounds[0], bounds[1], true)
          ?.trim();
        if (!currentText) return;

        onEnter(currentText);
        textBuffer.set_text("", 0);
        // }
      }}
    >
      <box className={className}>{textView}</box>
    </eventbox>
  );
}
