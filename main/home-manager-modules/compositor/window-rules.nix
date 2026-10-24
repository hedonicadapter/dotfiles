# Window rules for niri and Hyprland. Regexes match like niri's (unanchored
# search); the Hyprland renderer wraps them for its full-match engine.
[
  # Translucent unfocused windows; video stays opaque
  {
    match.active = false;
    exclude.appId = "^mpv$";
    opacity = 0.6;
  }

  {
    match.appId = "popup";
    float = true;
    # Hyprland only: niri already centers new floating windows
    center = true;
    stayFocused = true;
  }

  {
    match.title = "^Picture-in-Picture$";
    float = true;
  }

  # niri only: Hyprland has no at-startup match and starts obsidian silently
  {
    match = {
      appId = "obsidian";
      atStartup = true;
    };
    focus = false;
  }

  # Steam toasts are its own X11 windows, not freedesktop notifications
  {
    match = {
      appId = "steam";
      title = ''^notificationtoasts_\d+_desktop$'';
    };
    float = true;
    focus = false;
    position = {
      x = 10;
      y = 10;
      relativeTo = "bottom-right";
    };
  }
]
