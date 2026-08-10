import app from "ags/gtk3/app";
import Gtk from "gi://Gtk?version=3.0";
import { createBinding, For } from "ags";
import Tray from "gi://AstalTray";

export default function SysTrayComponent() {
  const tray = Tray.get_default();

  return (
    <box
      class="bar-item tray"
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
    >
      <For each={createBinding(tray, "items")}>
        {(item) => {
          if (item.iconThemePath) app.add_icons(item.iconThemePath);

          return (
            <menubutton
              tooltipMarkup={createBinding(item, "tooltipMarkup")}
              usePopover={false}
              actionGroup={createBinding(item, "action-group").as((ag) => [
                "dbusmenu",
                ag,
              ])}
              menuModel={createBinding(item, "menu-model")}
            >
              <icon gicon={createBinding(item, "gicon")} />
            </menubutton>
          );
        }}
      </For>
    </box>
  );
}
