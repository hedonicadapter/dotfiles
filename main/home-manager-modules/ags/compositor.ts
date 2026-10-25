// Picks the backend from whichever compositor socket is live; widgets import
// state and actions from here only.
import GLib from "gi://GLib";
import * as hyprland from "./compositor/hyprland";
import * as niri from "./compositor/niri";
import type { Backend } from "./compositor/state";

export * from "./compositor/state";

// Without a compositor the bar still renders, just with empty state
const none: Backend = {
  connect: () =>
    console.error("compositor: neither niri nor Hyprland found, no workspace state"),
  focusWorkspace: () => {},
  loadKeybinds: () => [],
};

// The systemd user environment can outlive a session, so check the socket too
function live(path: string | null) {
  return !!path && GLib.file_test(path, GLib.FileTest.EXISTS);
}

function pick(): Backend {
  if (live(GLib.getenv("NIRI_SOCKET"))) return niri;

  const signature = GLib.getenv("HYPRLAND_INSTANCE_SIGNATURE");
  if (
    signature &&
    live(`${GLib.get_user_runtime_dir()}/hypr/${signature}/.socket2.sock`)
  )
    return hyprland;

  return none;
}

export const { connect, focusWorkspace, loadKeybinds } = pick();
