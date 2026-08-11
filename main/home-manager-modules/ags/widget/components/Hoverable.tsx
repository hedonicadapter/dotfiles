import Gtk from "gi://Gtk?version=3.0"
import { createState, createBinding } from "ags";

export default function ({
  main,
  hoveredElement,
  class,
  enable = true,
}: {
  main: JSX.Element;
  hoveredElement: JSX.Element;
  class?: string;
  enable?: boolean;
}) {
  const [hovered, setHovered] = createState(false);

  return (
    <eventbox
      onHover={() => enable && setHovered(true)}
      onHoverLost={() => enable && setHovered(false)}
      onDestroy={() => hovered.drop()}
      valign={Gtk.Align.CENTER}
    >
      <box
        class={hovered((h) =>
          h ? `bar-item ${class} hovered` : `bar-item ${className}`,
        )}
        vertical
        valign={Gtk.Align.CENTER}
      >
        {main}

        <box visible={createBinding(hovered)} valign={Gtk.Align.CENTER}>
          {hoveredElement}
        </box>
      </box>
    </eventbox>
  );
}
