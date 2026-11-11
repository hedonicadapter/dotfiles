// Shared timing from compositor/animations.nix, written to animations.json
// by home.nix. A missing role means "no animation".
import GLib from "gi://GLib";
import { readFile } from "ags/file";

export type Timing = {
  curve: [number, number, number, number];
  ms: number;
  holdMs?: number;
};

let roles: Record<string, Timing | null> | null = null;

export function timing(role: string): Timing | null {
  if (!roles) {
    try {
      roles = JSON.parse(readFile(`${SRC}/animations.json`));
    } catch (e) {
      console.error("animations: no animations.json, animating nothing", e);
      roles = {};
    }
  }
  return roles?.[role] ?? null;
}

// CSS cubic-bezier(x1, y1, x2, y2) as progress -> eased progress
export function cubicBezier(x1: number, y1: number, x2: number, y2: number) {
  const coord = (t: number, a: number, b: number) =>
    3 * a * t * (1 - t) ** 2 + 3 * b * t ** 2 * (1 - t) + t ** 3;

  return (x: number) => {
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    // Bisection on x(t); 20 rounds is well under a pixel
    let lo = 0;
    let hi = 1;
    for (let i = 0; i < 20; i++) {
      const mid = (lo + hi) / 2;
      if (coord(mid, x1, x2) < x) lo = mid;
      else hi = mid;
    }
    return coord((lo + hi) / 2, y1, y2);
  };
}

const FRAME_MS = 16;

// Steps from -> to on the role's curve; returns a cancel function
export function tween(
  from: number,
  to: number,
  role: Timing | null,
  step: (value: number) => void,
) {
  if (!role || role.ms <= 0 || from === to) {
    step(to);
    return () => {};
  }

  const ease = cubicBezier(...role.curve);
  const now = () => GLib.get_monotonic_time() / 1000;
  const start = now();
  const id = setInterval(() => {
    const progress = Math.min(1, (now() - start) / role.ms);
    step(from + (to - from) * ease(progress));
    if (progress >= 1) clearInterval(id);
  }, FRAME_MS);

  return () => clearInterval(id);
}
