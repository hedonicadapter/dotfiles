import { Gdk } from "ags/gtk3";
import Gtk from "gi://Gtk?version=3.0"

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
  class,
  hexpand,
  vexpand,
}: {
  onEnter: (currentText: string) => void;
  class?: string;
  hexpand?: boolean;
  vexpand?: boolean;
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
      <box class={className} hexpand={hexpand} vexpand={vexpand}>
        {textView}
      </box>
    </eventbox>
  );
}
