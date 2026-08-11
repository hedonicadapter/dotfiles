import { createState } from "ags";
import Gtk from "gi://Gtk?version=3.0";

export default function ({
  main,
  hoveredElement,
  class: className,
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
      valign={Gtk.Align.CENTER}
    >
      <box
        class={hovered.as((h) =>
          h ? `bar-item ${className} hovered` : `bar-item ${className}`,
        )}
        vertical
        valign={Gtk.Align.CENTER}
      >
        {main}

        <box visible={hovered} valign={Gtk.Align.CENTER}>
          {hoveredElement}
        </box>
      </box>
    </eventbox>
  );
}
