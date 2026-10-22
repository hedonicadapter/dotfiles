# Plan: decouple config from the window manager

Goal: niri and Hyprland both usable from the same config, chosen at login.
Switching compositors should be a login choice, not a port.

## Current coupling

| Piece | Compositor-specific? |
|---|---|
| AGS bar, tofi, which-key, notifications, cliphist, swww/mpvpaper wallpapers | No — layer-shell, works on both |
| AGS compositor state (workspaces, focused window/output, keyboard layout) | Yes — only via `ags/niri.ts`: 5 import sites + one action (`FocusWorkspace`) |
| AGS keybind overlay (`ags/keybinds.ts`) | Yes — parses niri's `config.kdl` |
| Autostart | Duplicated: `niri/auto-start.sh` and `hyprland/auto-start.sh`, already drifted |
| Monitors per host, window rules, launcher binds | Written twice: niri KDL and Hyprland Lua |
| HDMI res/refresh toggle (`wlr-which-key/menus.nix`), wallpaper resolution check | Call `niri msg` / `hyprctl` directly |
| CRT / colour-temperature screen shader, tearing, dwindle | Genuinely compositor-specific |

## Steps

### 1. AGS compositor layer

- Add `ags/compositor.ts` exporting the state widgets use today:
  `workspaces`, `focusedWorkspace`, `focusedOutput`, `focusedWindow`,
  `overviewOpen`, `keyboardLayout`, plus `connect()` and `focusWorkspace(id)`.
- Backends: `ags/compositor/niri.ts` (current `niri.ts`, moved) and
  `ags/compositor/hyprland.ts` (AstalHyprland, mapped to the same shapes).
- Pick at startup: `NIRI_SOCKET` → niri, `HYPRLAND_INSTANCE_SIGNATURE` → Hyprland,
  neither → static empty state (bar still renders).
- Point the 5 importers (`app.ts`, `Bar.tsx`, `Outline.tsx`, `TitleComponent.tsx`,
  `WorkspaceComponent.tsx`) at `compositor.ts`; replace `niriAction(...)` with
  `focusWorkspace(id)`.
- `keybinds.ts`: niri → parse `config.kdl` (as now); Hyprland → `hyprctl binds -j`.
- Done when: headless render shows workspaces and title under nested niri and
  nested Hyprland.

### 2. Autostart as systemd user services

- `ags`, `wl-clip-persist`, `cliphist` text + image watchers as user services,
  `PartOf`/`WantedBy = graphical-session.target` (both sessions reach it).
- `niri-autotile` service with `ConditionEnvironment=NIRI_SOCKET`.
- Hyprland: enable home-manager's `wayland.windowManager.hyprland.systemd` so it
  reaches `graphical-session.target`.
- Delete both `auto-start.sh`. Fixes a live bug: Hyprland's runs `ags run`
  without `&`, so the clipboard tools after it never start.
- Done when: `systemctl --user status ags cliphist-*` is active in both sessions.

### 3. Shared data in Nix, rendered per compositor

- `hosts/<host>/display.nix` (or similar): outputs with mode, scale, position, VRR.
  Desktop: `HDMI-A-1` 1920x1080@240, scale 1. Laptop: current values.
- `window-rules.nix`: list of `{ match = { appId; title; }; float; focus; position; opacity; }`.
  Current rules: Steam toasts, Obsidian at startup, PiP, `popup`, inactive opacity, blur.
- `launcher-binds.nix`: spawn binds (which-key menus, hints, terminal…).
- Generators: `niri/config.kdl.nix` and `hyprland/hyprland.lua.nix` consume these.
  Layout binds stay per compositor (niri columns ≠ Hyprland dwindle).
- Done when: `niri validate` passes and Hyprland starts without config errors for
  both hosts; rendered outputs/rules match today's.

### 4. `wm` helper for scripts

- `writeShellApplication "wm"` with `outputs` (normalised JSON), `focused-output`,
  `set-mode <output> <WxH@R>`, `set-scale <output> <s>`, backed by `niri msg` or
  `hyprctl`.
- Use it in the HDMI toggle and the wallpaper service's resolution check.

## Stays compositor-specific

- Screen shader (`anti-sleep-neglector-gamma`): Hyprland only. Under niri, skip it
  and optionally fall back to `wlsunset` for colour temperature (no CRT effect).
- Tearing for games: Hyprland only (`allow_tearing` + `immediate` window rule);
  currently `allow_tearing = false`, VRR commented out.
- Layout behaviour and animations.

## Order

1 → 2 → 3 → 4. Steps 1 and 2 are small and unblock using Hyprland day to day;
step 3 is the bulk (mapping niri rule fields to Hyprland's).
