import Hyprland from "gi://AstalHyprland";
import Gtk from "gi://Gtk?version=3.0";
import Hoverable from "../Hoverable";
import { createState, createBinding } from "ags";

type Bind = {
  key: string;
  args?: string;
  description?: string;
};
export default function WorkspaceComponent() {
  const hypr = Hyprland.get_default();

  const [submapLabel, setSubmapLabel] = createState("NORMAL");
  const submapKeymaps = new Map<string, Bind[]>();

  hypr.get_binds().forEach((keybind) => {
    const kb = {
      key: keybind.key,
      args: keybind.args,
      description: keybind.description,
    };

    const current =
      (keybind.submap && keybind.submap.toUpperCase()) || "NORMAL";
    const saved = submapKeymaps.get(current);

    if (saved && saved.length > 0) submapKeymaps.set(current, [...saved, kb]);
    else submapKeymaps.set(current, [kb]);
  });

  hypr.connect("submap", (_: any, submap) => {
    const current = submap || "NORMAL";
    setSubmapLabel(current.toUpperCase());
  });

  return (
    <box
      class="bar-item workspaces"
      halign={Gtk.Align.START}
      valign={Gtk.Align.CENTER}
    >
      <box
        class="workspace-indicator"
        halign={Gtk.Align.START}
        valign={Gtk.Align.CENTER}
      >
        // TODO:
        {createBinding(hypr, "workspaces").as((wss) =>
          wss
            .sort((a, b) => a.id - b.id)
            .map((ws, index) => {
              if (index > 3) return <></>;
              return (
                <label
                  class="workspace"
                  // TODO:
                  label={createBinding(hypr, "focusedWorkspace").as((fw) =>
                    ws === fw ? "✦" : "✧",
                  )}
                />
              );
            }),
        )}
      </box>

      <box
        class="focused-workspace"
        halign={Gtk.Align.START}
        valign={Gtk.Align.CENTER}
      >
        // TODO:
        {createBinding(hypr, "focused-workspace").as((fws) => (
          <label class={fws.name} label={fws.name + " | "} />
        ))}
      </box>

      <Hoverable
        class="mode"
        main={
          <box class="main" halign={Gtk.Align.START} valign={Gtk.Align.CENTER}>
            <label
              class={createBinding(submapLabel)}
              label={submapLabel((l) => l.toUpperCase())}
            />
          </box>
        }
        hoveredElement={
          <box class="panel" vertical>
            {submapLabel(
              (l: string) =>
                submapKeymaps.get(l)?.map((v) => (
                  <box>
                    <label label={v.key} halign={Gtk.Align.START} />
                    <label
                      label={v.description ?? "NULL"}
                      halign={Gtk.Align.END}
                    />
                  </box>
                )) || <box />,
            )}
          </box>
        }
      />
    </box>
  );
}
