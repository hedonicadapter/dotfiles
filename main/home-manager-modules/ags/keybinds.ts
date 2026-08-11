// niri has no submaps and doesn't expose binds over IPC (hyprland's
// `get_binds()` had both), so the keybind panel reads config.kdl directly.
import GLib from "gi://GLib";
import { readFile } from "ags/file";

export type Keybind = {
  key: string;
  description: string;
};

const CONFIG_PATH = `${GLib.get_user_config_dir()}/niri/config.kdl`;

// Matches `Mod+Shift+H hotkey-overlay-title="..." { swap-window-left; }`
const BIND_RE = /^([A-Za-z0-9_+]+)\s+(.*?)\{\s*(.*?)\s*\}$/;
const TITLE_RE = /hotkey-overlay-title="([^"]*)"/;

function describe(props: string, action: string) {
  const title = props.match(TITLE_RE)?.[1];
  if (title) return title.toUpperCase();

  // Unhyphenate the action name only — arguments like "-30" keep their sign
  const [verb, ...args] = action.replace(/;\s*$/, "").split(/\s+/);

  return [verb.replace(/-/g, " "), ...args.map((a) => a.replace(/"/g, ""))]
    .join(" ")
    .trim()
    .toUpperCase();
}

export function parseKeybinds(kdl: string): Keybind[] {
  const binds: Keybind[] = [];
  let depth = 0;

  for (const raw of kdl.split("\n")) {
    const line = raw.replace(/\/\/.*$/, "").trim();
    if (!line) continue;

    if (depth === 0) {
      if (/^binds\s*\{/.test(line)) depth = 1;
      continue;
    }

    const match = line.match(BIND_RE);
    if (match) {
      binds.push({key: match[1], description: describe(match[2], match[3])});
      continue;
    }

    depth += (line.match(/\{/g)?.length ?? 0) - (line.match(/\}/g)?.length ?? 0);
    if (depth <= 0) break;
  }

  return binds;
}

export function loadKeybinds(): Keybind[] {
  try {
    return parseKeybinds(readFile(CONFIG_PATH));
  } catch (e) {
    console.error("niri: cannot read config.kdl for keybinds", e);
    return [];
  }
}
