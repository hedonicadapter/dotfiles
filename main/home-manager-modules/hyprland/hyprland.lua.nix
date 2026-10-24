{
  outputs,
  lib,
  inputs,
  pkgs,
  # home-manager-modules/compositor
  session,
  ...
}: let
  inherit (lib) boolToString concatMapStringsSep concatStringsSep mapAttrsToList optional optionalString;
  processColor = color: lib.toLower (builtins.substring 1 6 (builtins.toString color));

  hyprsplitSrc = inputs.hyprsplit.packages.${pkgs.system}.hyprsplitlua;

  # JSON strings and numbers are valid Lua literals
  lua = builtins.toJSON;
  # Shared regexes search like niri's; Hyprland's RE2 engine full-matches
  fullMatch = re: ".*(?:${re}).*";

  monitor = name: o: let
    mode =
      if o.mode == null
      then "preferred"
      else o.mode;
    position =
      if o.position == null
      then "auto"
      else "${toString o.position.x}x${toString o.position.y}";
  in "hl.monitor({ output = ${lua name}, mode = ${lua mode}, position = ${lua position}, scale = ${lua o.scale}${optionalString o.vrr ", vrr = 1"} })";

  # Monitor-local expressions for niri's relative-to corners
  move = {
    x,
    y,
    relativeTo,
  }: let
    fromRight = "monitor_w-window_w-${toString x}";
    fromBottom = "monitor_h-window_h-${toString y}";
    corners = {
      "top-left" = [(toString x) (toString y)];
      "top-right" = [fromRight (toString y)];
      "bottom-left" = [(toString x) fromBottom];
      "bottom-right" = [fromRight fromBottom];
    };
    xy = corners.${relativeTo} or (throw "hyprland: unsupported relative-to ${relativeTo}");
  in "{ ${lua (builtins.elemAt xy 0)}, ${lua (builtins.elemAt xy 1)} }";

  windowRule = r: let
    m = r.match;
    class =
      if m.appId != null && r.exclude.appId != null
      then throw "hyprland: a rule can't both match and exclude app-ids"
      else if m.appId != null
      then fullMatch m.appId
      else if r.exclude.appId != null
      then "negative:${fullMatch r.exclude.appId}"
      else null;
    # Focus-dependent opacity is Hyprland's "active inactive" pair
    opacity =
      if m.active == false
      then "1.0 ${lua r.opacity}"
      else if m.active == true
      then "${lua r.opacity} 1.0"
      else lua r.opacity;
    matches =
      optional (class != null) "class = ${lua class}"
      ++ optional (m.title != null) "title = ${lua (fullMatch m.title)}"
      ++ optional (m.active != null && r.opacity == null) "focus = ${boolToString m.active}";
    effects =
      optional (r.float != null) "float = ${boolToString r.float}"
      ++ optional (r.focus == false) "no_initial_focus = true"
      ++ optional (r.center != null) "center = ${boolToString r.center}"
      ++ optional (r.stayFocused != null) "stay_focused = ${boolToString r.stayFocused}"
      ++ optional (r.position != null) "move = ${move r.position}"
      ++ optional (r.opacity != null) "opacity = ${lua opacity}";
  in "hl.window_rule({ match = { ${concatStringsSep ", " matches} }, ${concatStringsSep ", " effects} })";
  # No at-startup match; startup apps open silently instead
  windowRules = builtins.filter (r: r.match.atStartup == null) session.windowRules;

  mods = {
    Mod = "SUPER";
    Shift = "SHIFT";
    Ctrl = "CTRL";
    Alt = "ALT";
  };
  launcherBind = b: let
    keys = concatStringsSep " + " (map (mod: mods.${mod}) b.mods ++ [b.key]);
  in "hl.bind(${lua keys}, hl.dsp.exec_cmd(${lua b.cmd}), { description = ${lua b.desc}${optionalString b.locked ", locked = true"} })";
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
    hl.exec_cmd("bash ~/.config/hypr/auto-float-unfloat.sh")

    hl.dispatch(hl.dsp.exec_cmd(terminal .. " --detach --hold -e nvim ~/big-todo.md", { workspace = "1 silent" }))
    hl.dispatch(hl.dsp.exec_cmd(browser, { workspace = "1 silent" }))
    hl.dispatch(hl.dsp.exec_cmd("obsidian", { workspace = "5 silent" }))
  end)

  -- env (set before display server init)
  -- hl.env("AQ_DRM_DEVICES", "/dev/dri/card0:/dev/dri/card1")

  hl.env("XCURSOR_SIZE", "100")
  hl.env("XCURSOR_THEME", "rah")
  hl.env("HYPRCURSOR_THEME", "rah")
  hl.env("HYPRCURSOR_SIZE", "100")

  hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
  hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
  hl.env("GSK_RENDERER", "ngl") -- error 71 gtk

  ${concatStringsSep "\n" (mapAttrsToList monitor session.outputs)}

  -- for AlfredoSequeida/hints
  -- hl.device({
  --  name = "ydotoold-virtual-device-1",
  --  accel_profile = "flat",
  -- })

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
      rounding = 0,

      -- Behind translucent unfocused windows (shared opacity rule), like niri
      blur = { enabled = true, size = 3, passes = 3, noise = 0.05 },
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

  ${concatMapStringsSep "\n" windowRule windowRules}
  hl.window_rule({ match = { class = "^mpv$" }, no_blur = true })

  package.path = package.path .. ";${hyprsplitSrc}/share/?/init.lua"
  local hs = require("hyprsplit")
  hs.config({
    num_workspaces = 4,
    persistent_workspaces = true,
  })

  ${concatMapStringsSep "\n" launcherBind session.launcherBinds}
  -- hl.bind("SUPER + Y", hl.dsp.exec_cmd("hints --mode scroll"))

  hl.bind(mainMod .. " + W", hl.dsp.window.close(), { description = "Close window" })
  hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float(), { description = "Toggle floating" })
  hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximize" })

  hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }), { description = "Focus left" })
  hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }), { description = "Focus right" })
  hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }), { description = "Focus up" })
  hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }), { description = "Focus down" })

  hl.bind(mainMod .. " + up", hl.dsp.window.cycle_next(), { description = "Cycle windows" })

  hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }), { description = "Move left" })
  hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }), { description = "Move right" })
  hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }), { description = "Move up" })
  hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }), { description = "Move down" })

  hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true, description = "Narrower" })
  hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true, description = "Wider" })
  hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true, description = "Shorter" })
  hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true, description = "Taller" })

  -- switch to Nth workspace on focused monitor
  for i = 1, 4 do
    hl.bind(mainMod .. " + " .. i, hs.dsp.focus({ workspace = i }), { description = "Focus workspace " .. i })
  end
  -- move active window to Nth workspace (follows focus); SHIFT+0 -> 10
  for i = 1, 10 do
    local key = (i == 10) and "0" or tostring(i)
    hl.bind(mainMod .. " + SHIFT + " .. key, hs.dsp.window.move({ workspace = i, follow = true }), { description = "Move to workspace " .. i })
  end

  -- move/resize with mainMod + LMB/RMB drag
  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
''
