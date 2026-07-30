"""Dwindle-ish auto-tiling for niri.

Niri always opens a new window in its own column, so a third window turns into
horizontal scroll instead of a split. This daemon watches the event stream and,
once a workspace already holds MAX_COLUMNS columns, folds each new window into
the neighbouring column with the fewest windows -- left on a tie, so a new
window splits the one that had focus, like hyprland's dwindle.

Tunables (env):
  NIRI_AUTOTILE_MAX_COLUMNS  columns allowed before folding starts (default 2)
  NIRI_AUTOTILE_MAX_TILES    windows per column before a new column is allowed
                             again; 0 = unlimited (default 2)
  NIRI_AUTOTILE_EXCLUDE      comma-separated app-ids to leave alone
"""

import json
import os
import subprocess
import sys
import time

MAX_COLUMNS = int(os.environ.get("NIRI_AUTOTILE_MAX_COLUMNS", "2"))
MAX_TILES = int(os.environ.get("NIRI_AUTOTILE_MAX_TILES", "2"))
EXCLUDE = {s for s in os.environ.get("NIRI_AUTOTILE_EXCLUDE", "").split(",") if s}

# Layout may not be resolved yet on the window's first event
RETRIES = 5
RETRY_DELAY = 0.02


def niri(*args):
    return subprocess.run(["niri", "msg", *args], capture_output=True, text=True, check=False)


def query_windows():
    result = niri("--json", "windows")
    if result.returncode != 0:
        return []
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return []


def column_of(window):
    pos = window["layout"]["pos_in_scrolling_layout"]
    return pos[0] if pos else None


def tiles_per_column(windows, workspace_id):
    """Map column index -> window count for one workspace's tiling layout."""
    counts = {}
    for window in windows:
        col = column_of(window)
        if window["workspace_id"] == workspace_id and col is not None and not window["is_floating"]:
            counts[col] = counts.get(col, 0) + 1
    return counts


def fold_target(counts, col):
    """Pick the neighbour column to fold into, or None to leave the window alone."""
    candidates = []
    for neighbour, direction in ((col - 1, "left"), (col + 1, "right")):
        size = counts.get(neighbour)
        if size is None:
            continue
        if MAX_TILES and size >= MAX_TILES:
            continue
        candidates.append((size, direction != "left", direction))
    if not candidates:
        return None
    return min(candidates)[2]


def handle_new_window(window_id):
    for _ in range(RETRIES):
        windows = query_windows()
        window = next((w for w in windows if w["id"] == window_id), None)
        if window is None:
            return
        if window["is_floating"] or (window["app_id"] or "") in EXCLUDE:
            return

        col = column_of(window)
        if col is None:
            time.sleep(RETRY_DELAY)
            continue

        counts = tiles_per_column(windows, window["workspace_id"])
        if len(counts) <= MAX_COLUMNS or counts.get(col, 0) != 1:
            return

        direction = fold_target(counts, col)
        if direction:
            niri("action", f"consume-or-expel-window-{direction}", "--id", str(window_id))
        return


def main():
    stream = subprocess.Popen(
        ["niri", "msg", "--json", "event-stream"],
        stdout=subprocess.PIPE,
        text=True,
        bufsize=1,
    )
    seen = set()

    for line in stream.stdout:
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue

        if "WindowsChanged" in event:
            seen = {w["id"] for w in event["WindowsChanged"]["windows"]}
        elif "WindowClosed" in event:
            seen.discard(event["WindowClosed"]["id"])
        elif "WindowOpenedOrChanged" in event:
            window_id = event["WindowOpenedOrChanged"]["window"]["id"]
            if window_id not in seen:
                seen.add(window_id)
                handle_new_window(window_id)

    return stream.wait()


if __name__ == "__main__":
    sys.exit(main())
