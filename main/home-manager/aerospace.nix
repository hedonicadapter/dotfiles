{pkgs, ...}: let
  aerospaceConfig = ''
    after-login-command = ["layout tiles"]
    after-startup-command = []
    default-root-container-layout = "tiles"
    default-root-container-orientation = "auto"
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true
    exec-on-workspace-change = []
    on-focus-changed = ["move-mouse window-lazy-center"]
    on-focused-monitor-changed = ["move-mouse monitor-lazy-center"]
    on-window-detected = []
    start-at-login = true

    [exec.env-vars]
    TERMINAL = 'kitty'
    DEFAULT_BROWSER = 'zen'

    [gaps.inner]
    horizontal = [{monitor."^built-in retina display$" = 12}, { monitor.main = 18 }, 12]
    vertical = [{monitor."^built-in retina display$" = 12}, { monitor.main = 18 }, 12]

    [gaps.outer]
    bottom = [{monitor."^built-in retina display$" = 12}, { monitor.main = 42 }, 12]
    left = [{monitor."^built-in retina display$" = 12}, { monitor.main = 542 }, 12]
    right = [{monitor."^built-in retina display$" = 12}, { monitor.main = 542 }, 12]
    top = [{monitor."^built-in retina display$" = 12}, { monitor.main = 42 }, 12]

    [key-mapping]
    preset = "qwerty"

    [mode.main.binding]
    cmd-1 = "workspace 1"
    cmd-2 = "workspace 2"
    cmd-3 = "workspace 3"
    cmd-4 = "workspace 4"
    cmd-5 = "workspace 5"
    cmd-ctrl-h = "resize width -30"
    cmd-ctrl-j = "resize height +30"
    cmd-ctrl-k = "resize height -30"
    cmd-ctrl-l = "resize width +30"
    cmd-d = "mode directories"
    cmd-h = "focus left"
    cmd-j = "focus down"
    cmd-k = "focus up"
    cmd-l = "focus right"
    cmd-m = "fullscreen"
    cmd-shift-1 = ["move-node-to-workspace 1", "workspace 1"]
    cmd-shift-2 = ["move-node-to-workspace 2", "workspace 2"]
    cmd-shift-3 = ["move-node-to-workspace 3", "workspace 3"]
    cmd-shift-4 = ["move-node-to-workspace 4", "workspace 4"]
    cmd-shift-5 = ["move-node-to-workspace 5", "workspace 5"]
    cmd-shift-r = "reload-config"
    cmd-shift-f = "layout floating tiling"
    cmd-shift-h = "move left"
    cmd-shift-j = "move down"
    cmd-shift-k = "move up"
    cmd-shift-l = "move right"
    cmd-w = "close --quit-if-last-window"
    cmd-alt-h = []

    cmd-u = "mode utility"
    cmd-b = "mode browser"
    cmd-q = "mode query"
    cmd-r = "mode run"
    cmd-s = "mode system"

    [mode.powermenu.binding]
    esc = "mode system"

    [mode.query.binding]
    esc = "mode main"

    [mode.run.binding]
    esc = "mode main"
    t = ["exec-and-forget open -na $TERMINAL", "mode main"]

    [mode.system.binding]
    a = "mode audio"
    d = "mode display"
    p = "mode powermenu"
    esc = "mode main"

    [mode.utility.binding]
    p = ["exec-and-forget screencapture -i -c", "mode main"]
    esc = "mode main"

    [mode.audio.binding]
    j = "volume down"
    k = "volume up"
    esc = "mode system"

    [mode.browser.binding]
    d = ["exec-and-forget open -na $DEFAULT_BROWSER", "mode main"]
    z = ["exec-and-forget open -na Zen", "mode main"]
    s = ["exec-and-forget open -na Safari", "mode main"]
    esc = "mode main"

    [mode.directories.binding]
    d = ["exec-and-forget open ~/Downloads", "mode main"]
    p = ["exec-and-forget open ~/Documents/projects", "mode main"]
    t = ["exec-and-forget open ~/.Trash", "mode main"]
    esc = "mode main"

    [mode.display.binding]
    esc = "mode system"

    [workspace-to-monitor-force-assignment]
  '';
in {
  home.packages = with pkgs; [
    aerospace
  ];
  home.file.".aerospace.toml".text = aerospaceConfig;
}
