import { bind } from "astal";
import { Gtk } from "astal/gtk3";
import Hoverable from "../Hoverable";
import { loadKeybinds } from "../../../keybinds";
import {
  focusedWorkspace,
  niriAction,
  NiriWorkspace,
  overviewOpen,
  workspaces,
} from "../../../niri";

const MAX_INDICATORS = 4;

export default function WorkspaceComponent({monitor}: {monitor?: string}) {
  const keybinds = loadKeybinds();

  // niri has no submaps — overview is the only modal state
  const mode = bind(overviewOpen).as((open) => (open ? "OVERVIEW" : "NORMAL"));

  const onThisMonitor = (wss: NiriWorkspace[]) =>
    wss.filter((ws) => !monitor || ws.output === monitor);

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
        {bind(workspaces).as((wss) =>
          onThisMonitor([...wss])
            .sort((a, b) => a.idx - b.idx)
            .slice(0, MAX_INDICATORS)
            .map((ws) => (
              <eventbox
                onClick={() =>
                  niriAction({FocusWorkspace: {reference: {Id: ws.id}}})
                }
              >
                <label className="workspace" label={ws.is_active ? "✦" : "✧"} />
              </eventbox>
            )),
        )}
      </box>

      <box
        className="focused-workspace"
        halign={Gtk.Align.START}
        valign={Gtk.Align.CENTER}
      >
        {bind(workspaces).as((wss) => {
          const active =
            onThisMonitor(wss).find((ws) => ws.is_active) ??
            focusedWorkspace.get();
          const name = active?.name ?? String(active?.idx ?? "");

          return <label className={`workspace-${name}`} label={name + " | "} />;
        })}
      </box>

      <Hoverable
        className="mode"
        main={
          <box
            className="main"
            halign={Gtk.Align.START}
            valign={Gtk.Align.CENTER}
          >
            <label className={mode} label={mode} />
          </box>
        }
        hoveredElement={
          <scrollable
            className="panel"
            hscroll={Gtk.PolicyType.NEVER}
            vscroll={Gtk.PolicyType.AUTOMATIC}
            heightRequest={400}
          >
            <box vertical>
              {keybinds.map((kb) => (
                <box>
                  <label label={kb.key} halign={Gtk.Align.START} hexpand />
                  <label label={kb.description} halign={Gtk.Align.END} />
                </box>
              ))}
            </box>
          </scrollable>
        }
      />
    </box>
  );
}
