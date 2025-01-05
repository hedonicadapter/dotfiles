import { App, Gtk } from "astal/gtk3";
import { bind } from "astal";
import Tray from "gi://AstalTray";

export default function SysTrayComponent() {
  const tray = Tray.get_default();

  return (
    <box
      className="bar-item tray"
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
    >
      {bind(tray, "items").as((items) =>
        items.map((item) => {
          if (item.iconThemePath) App.add_icons(item.iconThemePath);

          return (
            <menubutton
              tooltipMarkup={bind(item, "tooltipMarkup")}
              usePopover={false}
              actionGroup={bind(item, "action-group").as((ag) => [
                "dbusmenu",
                ag,
              ])}
              menuModel={bind(item, "menu-model")}
            >
              <icon gicon={bind(item, "gicon")} />
            </menubutton>
          );
        }),
      )}
    </box>
  );
}
