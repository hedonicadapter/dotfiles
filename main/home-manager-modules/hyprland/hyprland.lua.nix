{
  outputs,
  lib,
  inputs,
  ...
}: let
  processColor = color: lib.toLower (builtins.substring 1 6 (builtins.toString color));

  # split-monitor-workspaces is a lua library now (>= 0.55), not a .so
  smwSrc = inputs.split-monitor-workspaces;
in ''
  local mainMod = "SUPER"

  local terminal    = "kitty"
  -- local editor   = "neovide"
  local fileManager = "nautilus"
  local menu        = "tofi-run"
  local mail        = "xdg-open https://mail.google.com"
  local browser     = "zen-beta"
  local music       = "spotify"

  -- autostart
  hl.on("hyprland.start", function()
    hl.exec_cmd("bash ~/.config/hypr/auto-start.sh")
    hl.exec_cmd("bash ~/.config/hypr/auto-float-unfloat.sh")

    hl.dispatch(hl.dsp.exec_cmd(terminal .. " --detach --hold -e nvim ~/big-todo.md", { workspace = "1 silent" }))
    hl.dispatch(hl.dsp.exec_cmd(browser, { workspace = "1 silent" }))
    hl.dispatch(hl.dsp.exec_cmd("obsidian", { workspace = "5 silent" }))
  end)

  -- env (set before display server init)
  hl.env("AQ_DRM_DEVICES", "/dev/dri/card0:/dev/dri/card1")

  hl.env("XCURSOR_SIZE", "100")
  hl.env("XCURSOR_THEME", "rah")
  hl.env("HYPRCURSOR_THEME", "rah")
  hl.env("HYPRCURSOR_SIZE", "100")

  hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
  hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
  hl.env("GSK_RENDERER", "ngl") -- error 71 gtk

  hl.monitor({ output = "eDP-1",    mode = "2150x1440", position = "auto",       scale = 1 })
  hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "2160x0",     scale = 0.75 })

  -- Xenit
  hl.monitor({ output = "DP-3", mode = "preferred", position = "2560x-1440", scale = 1 })
  hl.monitor({ output = "DP-4", mode = "preferred", position = "5120x-1440", scale = 1 })
  hl.monitor({ output = "DP-1", mode = "preferred", position = "auto",       scale = 1 })

  -- for AlfredoSequeida/hints
  hl.device({
    name = "ydotoold-virtual-device-1",
    accel_profile = "flat",
  })

  hl.config({
    xwayland = {
      force_zero_scaling = true,
      use_nearest_neighbor = false,
    },

    input = {
      kb_layout = "se",

      accel_profile = "adaptive",
      -- accel_profile = "custom 4 0.3 0.4 0.75 0.9 0.95 1.0",
      -- sensitivity = 1.0,

      follow_mouse = 1,

      repeat_rate = 20,
      repeat_delay = 200,

      touchpad = {
        natural_scroll = true,
      },
    },

    general = {
      gaps_in = 8,
      gaps_out = 16,
      border_size = 1,
      ["col.active_border"] = "rgb(${processColor outputs.palette.base04})",
      ["col.inactive_border"] = "rgb(${processColor outputs.palette.base03})",

      layout = "dwindle",

      allow_tearing = false,
      no_focus_fallback = true,
    },

    debug = {
      damage_tracking = 0,
      vfr = true, -- was misc.vfr
    },

    decoration = {
      dim_inactive = true,
      dim_strength = 0.3,

      rounding = 0,

      blur = { enabled = false },
      shadow = { enabled = false },
    },

    animations = {
      enabled = true,
    },

    dwindle = {
      preserve_split = true,
    },

    -- gestures.workspace_swipe removed upstream; it was off

    misc = {
      force_default_wallpaper = -1,
      disable_hyprland_logo = true,
      disable_splash_rendering = true,
      focus_on_activate = false,
      animate_manual_resizes = true,
      on_focus_under_fullscreen = 2, -- was new_window_takes_over_fullscreen=2; verify feel
      initial_workspace_tracking = 0,
      -- vrr = 2,
    },

    opengl = {
      nvidia_anti_flicker = false,
    },

    render = {
      direct_scanout = 2,
    },

    binds = {
      workspace_center_on = 1,
    },
  })

  hl.curve("myBezier",    { type = "bezier", points = { {0, 0},       {0.58, 1} } })
  hl.curve("easeOutBack", { type = "bezier", points = { {0.34, 1.56}, {0.64, 1} } })

  hl.animation({ leaf = "layers",     enabled = true, speed = 0.5, bezier = "myBezier" })
  hl.animation({ leaf = "fade",       enabled = true, speed = 0.5, bezier = "myBezier" })
  hl.animation({ leaf = "windows",    enabled = true, speed = 0.5, bezier = "myBezier", style = "slide" })
  hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.5, bezier = "myBezier", style = "slide" })
  hl.animation({ leaf = "workspaces", enabled = true, speed = 0.5, bezier = "myBezier" })

  -- hl.animation({ leaf = "border",      enabled = true, speed = 3.5,  bezier = "myBezier" })
  -- hl.animation({ leaf = "borderangle", enabled = true, speed = 11.5, bezier = "easeOutBack" })

  -- last-wins overrides for windows/workspaces
  hl.curve("easeOutQuart", { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })
  hl.animation({ leaf = "windows",    enabled = true, speed = 3.5, bezier = "easeOutQuart", style = "popin" })
  hl.animation({ leaf = "workspaces", enabled = true, speed = 3.5, bezier = "easeOutQuart", style = "slide" })

  hl.workspace_rule({ workspace = "1",  default_name = "main" })
  hl.workspace_rule({ workspace = "2",  default_name = "misc" })
  hl.workspace_rule({ workspace = "3",  default_name = "misc" })
  hl.workspace_rule({ workspace = "4",  default_name = "misc" })
  hl.workspace_rule({ workspace = "5",  default_name = "misc" })
  hl.workspace_rule({ workspace = "6",  default_name = "misc" })
  hl.workspace_rule({ workspace = "7",  default_name = "misc" })
  hl.workspace_rule({ workspace = "8",  default_name = "misc" })
  hl.workspace_rule({ workspace = "9",  default_name = "misc" })
  hl.workspace_rule({ workspace = "10", default_name = "misc" })

  hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
  hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
  hl.window_rule({ match = { float = false, workspace = "f[1]" },   border_size = 0 })
  hl.window_rule({ match = { float = false, workspace = "f[1]" },   rounding = 0 })

  hl.window_rule({ match = { class = "^(.*popup.*)$" }, float = true })
  hl.window_rule({ match = { class = "^(.*popup.*)$" }, center = true })
  hl.window_rule({ match = { class = "^(.*popup.*)$" }, stay_focused = true })

  package.path = package.path .. ";${smwSrc}/lua/?.lua"
  local smw = require("split-monitor-workspaces")
  smw.setup({
    workspace_count = 4,
    enable_notifications = false,
  })

  -- Which-key menus (wlr-which-key), shared with niri.
  -- Menu contents live in home-manager-modules/wlr-which-key/menus.nix
  hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("wlr-which-key-run"))
  hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("wlr-which-key-browser"))
  hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("wlr-which-key-directories"))
  hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd("wlr-which-key-query"))
  hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("wlr-which-key-utility"))
  hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("wlr-which-key-system"))

  hl.bind("SUPER + V", hl.dsp.exec_cmd("hints"))
  -- hl.bind("SUPER + Y", hl.dsp.exec_cmd("hints --mode scroll"))

  hl.bind(mainMod .. " + W", hl.dsp.window.close())
  hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float())
  hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))

  hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
  hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
  hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
  hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

  hl.bind(mainMod .. " + up", hl.dsp.window.cycle_next())

  hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
  hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
  hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
  hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))

  hl.bind(mainMod .. " + Control_L + H", hl.dsp.window.resize({ x = -30, y = 0,   relative = true }), { repeating = true })
  hl.bind(mainMod .. " + Control_L + L", hl.dsp.window.resize({ x = 30,  y = 0,   relative = true }), { repeating = true })
  hl.bind(mainMod .. " + Control_L + K", hl.dsp.window.resize({ x = 0,   y = -30, relative = true }), { repeating = true })
  hl.bind(mainMod .. " + Control_L + J", hl.dsp.window.resize({ x = 0,   y = 30,  relative = true }), { repeating = true })

  -- switch to Nth workspace on focused monitor
  for i = 1, 4 do
    hl.bind(mainMod .. " + " .. i, smw.workspace(tostring(i)))
  end
  -- move active window to Nth workspace (follows focus); SHIFT+0 -> 10
  for i = 1, 10 do
    local key = (i == 10) and "0" or tostring(i)
    hl.bind(mainMod .. " + SHIFT + " .. key, smw.move_to_workspace(tostring(i)))
  end

  -- move/resize with mainMod + LMB/RMB drag
  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
''
