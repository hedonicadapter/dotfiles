import Tray from "gi://AstalTray";
import { createBinding } from "ags";
import app from "ags/gtk3/app";
import Gtk from "gi://Gtk?version=3.0";

export default function SysTrayComponent() {
  const tray = Tray.get_default();

  return (
    <box
      class="bar-item tray"
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
    >
      // TODO:
      {createBinding(tray, "items").as((items) =>
        items.map((item) => {
          if (item.iconThemePath) app.add_icons(item.iconThemePath);

          return (
            <menubutton
              tooltipMarkup={createBinding(item, "tooltipMarkup")}
              usePopover={false}
              // TODO:
              actionGroup={createBinding(item, "action-group").as((ag) => [
                "dbusmenu",
                ag,
              ])}
              menuModel={createBinding(item, "menu-model")}
            >
              <icon gicon={createBinding(item, "gicon")} />
            </menubutton>
          );
        }),
      )}
    </box>
  );
}
