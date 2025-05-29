import { bind, Variable } from "astal";
import { Gtk } from "astal/gtk3";

export default function ({
  main,
  hoveredElement,
  className,
  enable = true,
}: {
  main: JSX.Element;
  hoveredElement: JSX.Element;
  className?: string;
  enable?: boolean;
}) {
  const hovered = Variable(false);

  return (
    <eventbox
      onHover={() => enable && hovered.set(true)}
      onHoverLost={() => enable && hovered.set(false)}
      onDestroy={() => hovered.drop()}
      valign={Gtk.Align.CENTER}
    >
      <box
        className={bind(hovered).as((h) =>
          h ? `bar-item ${className} hovered` : `bar-item ${className}`,
        )}
        vertical
        valign={Gtk.Align.CENTER}
      >
        {main}

        <box visible={bind(hovered)} valign={Gtk.Align.CENTER}>
          {hoveredElement}
        </box>
      </box>
    </eventbox>
  );
}
