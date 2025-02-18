import Hyprland from "gi://AstalHyprland";
import { bind, Variable } from "astal";
import { Gtk } from "astal/gtk3";
import Hoverable from "../Hoverable";

type Bind = {
  key: string;
  args?: string;
  description?: string;
};
export default function WorkspaceComponent() {
  const hypr = Hyprland.get_default();

  const submapLabel = Variable("NORMAL");
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
    submapLabel.set(current.toUpperCase());
  });

  return (
    <box
      className="bar-item workspaces"
      halign={Gtk.Align.START}
      valign={Gtk.Align.CENTER}
    >
      <box
        className="workspace-indicator"
        halign={Gtk.Align.START}
        valign={Gtk.Align.CENTER}
      >
        {bind(hypr, "workspaces").as((wss) =>
          wss
            .sort((a, b) => a.id - b.id)
            .map((ws, index) => {
              if (index > 3) return <></>;
              return (
                <label
                  className="indicator workspace"
                  label={bind(hypr, "focusedWorkspace").as((fw) =>
                    ws === fw ? "✦" : "✧",
                  )}
                />
              );
            }),
        )}
      </box>

      <box
        className="focused-workspace"
        halign={Gtk.Align.START}
        valign={Gtk.Align.CENTER}
      >
        {bind(hypr, "focused-workspace").as((fws) => (
          <label className={fws.name} label={fws.name + " | "} />
        ))}
      </box>

      <Hoverable
        className="mode"
        main={
          <box
            className="main"
            onDestroy={() => submapLabel.drop()}
            halign={Gtk.Align.START}
            valign={Gtk.Align.CENTER}
          >
            <label
              className={bind(submapLabel)}
              label={bind(submapLabel).as((l) => l.toUpperCase())}
            />
          </box>
        }
        hoveredElement={
          <box className="panel" vertical>
            {bind(submapLabel).as(
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
