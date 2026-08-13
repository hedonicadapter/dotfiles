import Gtk from "gi://Gtk?version=3.0";
import Gdk from "gi://Gdk?version=3.0";

export default function ({
  onEnter,
  class: className,
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

  // Submit on Enter only — this used to fire onEnter for every keystroke.
  // Bound on both the TextView and the wrapping eventbox since either can hold
  // focus; the deeper one runs first and stops propagation once it submits.
  const onKeyPress = (_: unknown, evt: Gdk.Event) => {
    const keyval = evt.get_keyval()[1];
    if (keyval !== Gdk.KEY_Return && keyval !== Gdk.KEY_KP_Enter) return false;

    // Shift+Enter inserts a newline instead of submitting
    const [, state] = evt.get_state();
    if (state & Gdk.ModifierType.SHIFT_MASK) return false;

    const bounds = textBuffer.get_bounds();
    const currentText = textBuffer
      .get_text(bounds[0], bounds[1], true)
      ?.trim();
    if (!currentText) return true;

    onEnter(currentText);
    textBuffer.set_text("", 0);
    return true;
  };

  textView.connect("key-press-event", onKeyPress);

  return (
    <eventbox onKeyPressEvent={onKeyPress}>
      <box class={className} hexpand={hexpand} vexpand={vexpand}>
        {textView}
      </box>
    </eventbox>
  );
}
