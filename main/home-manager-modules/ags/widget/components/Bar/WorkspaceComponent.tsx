import { createComputed, For } from "ags";
import Gtk from "gi://Gtk?version=3.0";
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
  const mode = overviewOpen.as((open) => (open ? "OVERVIEW" : "NORMAL"));

  const onThisMonitor = (wss: NiriWorkspace[]) =>
    wss.filter((ws) => !monitor || ws.output === monitor);

  const indicators = workspaces.as((wss) =>
    onThisMonitor([...wss])
      .sort((a, b) => a.idx - b.idx)
      .slice(0, MAX_INDICATORS),
  );

  const activeName = createComputed(
    [workspaces, focusedWorkspace],
    (wss, focused) => {
      const active = onThisMonitor(wss).find((ws) => ws.is_active) ?? focused;
      return active?.name ?? String(active?.idx ?? "");
    },
  );

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
        <For each={indicators}>
          {(ws) => (
            <eventbox
              onClick={() =>
                niriAction({FocusWorkspace: {reference: {Id: ws.id}}})
              }
            >
              <label class="workspace" label={ws.is_active ? "✦" : "✧"} />
            </eventbox>
          )}
        </For>
      </box>

      <box
        class="focused-workspace"
        halign={Gtk.Align.START}
        valign={Gtk.Align.CENTER}
      >
        <label
          class={activeName.as((name) => `workspace-${name}`)}
          label={activeName.as((name) => name + " | ")}
        />
      </box>

      <Hoverable
        class="mode"
        main={
          <box class="main" halign={Gtk.Align.START} valign={Gtk.Align.CENTER}>
            <label class={mode} label={mode} />
          </box>
        }
        hoveredElement={
          <scrollable
            class="panel"
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
