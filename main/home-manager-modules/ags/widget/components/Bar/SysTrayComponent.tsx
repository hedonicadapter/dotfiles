import app from "ags/gtk3/app";
import Gtk from "gi://Gtk?version=3.0";
import { createBinding, For, onCleanup } from "ags";
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
              menuModel={createBinding(item, "menu-model")}
              // Gtk.MenuButton has no action-group property — insert it by hand
              $={(self) => {
                const actionGroup = createBinding(item, "action-group");
                const apply = () =>
                  self.insert_action_group("dbusmenu", actionGroup.peek());

                apply();
                onCleanup(actionGroup.subscribe(apply));
              }}
            >
              <icon gicon={createBinding(item, "gicon")} />
            </menubutton>
          );
        }}
      </For>
    </box>
  );
}
