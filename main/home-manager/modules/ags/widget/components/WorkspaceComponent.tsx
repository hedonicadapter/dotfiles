import Hyprland from "gi://AstalHyprland";
import { bind } from "astal";

export default function WorkspaceComponent() {
  const hypr = Hyprland.get_default();

  return (
    <box className="Workspaces">
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
  );
}

// fw ?
