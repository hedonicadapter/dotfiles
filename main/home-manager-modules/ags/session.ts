// Shared settings from compositor/default.nix, written to session.json by
// home.nix. Empty when the file is missing; callers fall back to defaults
import { readFile } from "ags/file";

type Session = {
  animations?: Record<string, any>;
  screenGap?: number;
  windowGap?: number;
  barSpacing?: number;
};

function load(): Session {
  try {
    return JSON.parse(readFile(`${SRC}/session.json`));
  } catch (e) {
    console.error("session: no session.json, using defaults", e);
    return {};
  }
}

export const session = load();
