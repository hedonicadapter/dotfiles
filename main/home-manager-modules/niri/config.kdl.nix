{
  outputs,
  lib,
  # home-manager-modules/compositor
  session,
  ...
}: let
  inherit (lib) boolToString concatMapStrings concatMapStringsSep concatStringsSep hasInfix mapAttrsToList optional;
  p = outputs.palette;

  str = builtins.toJSON;
  # Raw string so regex backslashes survive
  raw = s: "r#\"${s}\"#";

  block = header: lines: "${header} {\n${concatMapStrings (l: "    ${l}\n") lines}}\n";

  outputBlock = name: o:
    block "output ${str name}" (
      optional (o.mode != null) "mode ${str o.mode}"
      ++ ["scale ${str o.scale}"]
      ++ optional (o.position != null) "position x=${toString o.position.x} y=${toString o.position.y}"
      ++ optional o.vrr "variable-refresh-rate"
      ++ optional o.focusAtStartup "focus-at-startup"
    );

  matcher = keyword: m: let
    props =
      optional (m.appId or null != null) "app-id=${raw m.appId}"
      ++ optional (m.title or null != null) "title=${raw m.title}"
      ++ optional (m.active or null != null) "is-active=${boolToString m.active}"
      ++ optional (m.atStartup or null != null) "at-startup=${boolToString m.atStartup}";
  in
    optional (props != []) (concatStringsSep " " ([keyword] ++ props));

  windowRule = r:
    block "window-rule" (
      matcher "match" r.match
      ++ matcher "exclude" r.exclude
      ++ optional (r.float != null) "open-floating ${boolToString r.float}"
      ++ optional (r.focus != null) "open-focused ${boolToString r.focus}"
      ++ optional (r.position != null)
      "default-floating-position x=${toString r.position.x} y=${toString r.position.y} relative-to=${str r.position.relativeTo}"
      ++ optional (r.opacity != null) "opacity ${str r.opacity}"
    );

  launcherBind = b: let
    props = ["hotkey-overlay-title=${str b.desc}"] ++ optional b.locked "allow-when-locked=true";
    action =
      if hasInfix " " b.cmd
      then "spawn-sh ${str b.cmd}"
      else "spawn ${str b.cmd}";
  in "    ${concatStringsSep "+" (b.mods ++ [b.key])} ${concatStringsSep " " props} { ${action}; }\n";
in ''
  input {
      keyboard {
          xkb {
              layout "se"
          }

          repeat-delay 200
          repeat-rate 20
      }

      touchpad {
          tap
          natural-scroll
      }

      mouse {
          accel-profile "adaptive"
      }

      focus-follows-mouse
      warp-mouse-to-focus mode="center-xy"
  }

  ${concatStringsSep "\n" (mapAttrsToList outputBlock session.outputs)}
  layout {
      gaps 16
      center-focused-column "on-overflow"
      always-center-single-column
      background-color "${p.base00}"

      preset-column-widths {
          proportion 0.33333
          proportion 0.5
          proportion 0.66667
      }

      default-column-width { proportion 0.5; }

      focus-ring {
          off
      }

      border {
          on
          width 1
          active-color "${p.base04}"
          inactive-color "${p.base03}"
          urgent-color "${p.base0E}"
      }

      shadow {
          off
      }

      tab-indicator {
          hide-when-single-tab
          place-within-column
          gap 4
          width 2
          position "left"
          active-color "${p.base04}"
          inactive-color "${p.base03}"
      }

      insert-hint {
          color "${p.base0D}80"
      }
  }

  cursor {
      xcursor-theme "rah"
      xcursor-size 100
  }

  environment {
      QT_QPA_PLATFORMTHEME "qt6ct"
      ELECTRON_OZONE_PLATFORM_HINT "auto"
      GSK_RENDERER "ngl"
  }

  spawn-sh-at-startup "kitty --detach --hold -e nvim ~/big-todo.md"
  spawn-at-startup "zen-beta"
  spawn-at-startup "obsidian"

  prefer-no-csd

  screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

  hotkey-overlay {
      skip-at-startup
  }

  overview {
      backdrop-color "${p.base00}"
  }

  // Noise is a blur sub-effect — only renders where blur is applied
  blur {
      passes 3
      offset 3
      noise 0.05
      saturation 1.5
  }

  ${concatMapStringsSep "\n" windowRule session.windowRules}
  // Blur+noise behind all windows; shows through the opacity rule above.
  // Keeps default xray — non-xray blur breaks the open/close shaders.
  window-rule {
      exclude app-id="^mpv$"
      background-effect {
          blur true
          noise 0.05
      }
  }

  binds {
      Mod+Shift+Slash { show-hotkey-overlay; }

  ${concatMapStrings launcherBind session.launcherBinds}
      Mod+W repeat=false { close-window; }

      Mod+Shift+F { toggle-window-floating; }
      Mod+Ctrl+Shift+F { switch-focus-between-floating-and-tiling; }

      Mod+M { maximize-window-to-edges; }
      Mod+Shift+M { fullscreen-window; }

      Mod+H     { focus-column-or-monitor-left; }
      Mod+J     { focus-window-down; }
      Mod+K     { focus-window-up; }
      Mod+L     { focus-column-or-monitor-right; }
      Mod+Left  { focus-column-or-monitor-left; }
      Mod+Down  { focus-window-down; }
      Mod+Up    { focus-window-up; }
      Mod+Right { focus-column-or-monitor-right; }

      // swap-window moves the window across columns, not the whole column.
      // Falls back to a column move when both columns hold a single window.
      Mod+Shift+H     { swap-window-left; }
      Mod+Shift+J     { move-window-down; }
      Mod+Shift+K     { move-window-up; }
      Mod+Shift+L     { swap-window-right; }
      Mod+Shift+Left  { swap-window-left; }
      Mod+Shift+Down  { move-window-down; }
      Mod+Shift+Up    { move-window-up; }
      Mod+Shift+Right { swap-window-right; }

      // Whole-column moves, incl. hopping to the next monitor
      Mod+Ctrl+Shift+H     { move-column-left-or-to-monitor-left; }
      Mod+Ctrl+Shift+L     { move-column-right-or-to-monitor-right; }
      Mod+Ctrl+Shift+Left  { move-column-left-or-to-monitor-left; }
      Mod+Ctrl+Shift+Right { move-column-right-or-to-monitor-right; }

      Mod+Ctrl+H { set-column-width "-30"; }
      Mod+Ctrl+L { set-column-width "+30"; }
      Mod+Ctrl+K { set-window-height "-30"; }
      Mod+Ctrl+J { set-window-height "+30"; }

      Mod+Alt+H     { focus-monitor-left; }
      Mod+Alt+J     { focus-monitor-down; }
      Mod+Alt+K     { focus-monitor-up; }
      Mod+Alt+L     { focus-monitor-right; }
      Mod+Alt+Left  { focus-monitor-left; }
      Mod+Alt+Down  { focus-monitor-down; }
      Mod+Alt+Up    { focus-monitor-up; }
      Mod+Alt+Right { focus-monitor-right; }

      Mod+Shift+Alt+H     { move-column-to-monitor-left; }
      Mod+Shift+Alt+J     { move-column-to-monitor-down; }
      Mod+Shift+Alt+K     { move-column-to-monitor-up; }
      Mod+Shift+Alt+L     { move-column-to-monitor-right; }
      Mod+Shift+Alt+Left  { move-column-to-monitor-left; }
      Mod+Shift+Alt+Down  { move-column-to-monitor-down; }
      Mod+Shift+Alt+Up    { move-column-to-monitor-up; }
      Mod+Shift+Alt+Right { move-column-to-monitor-right; }

      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }

      Mod+Shift+1 { move-window-to-workspace 1; }
      Mod+Shift+2 { move-window-to-workspace 2; }
      Mod+Shift+3 { move-window-to-workspace 3; }
      Mod+Shift+4 { move-window-to-workspace 4; }
      Mod+Shift+5 { move-window-to-workspace 5; }
      Mod+Shift+6 { move-window-to-workspace 6; }
      Mod+Shift+7 { move-window-to-workspace 7; }
      Mod+Shift+8 { move-window-to-workspace 8; }
      Mod+Shift+9 { move-window-to-workspace 9; }
      Mod+Shift+0 { move-window-to-workspace 10; }

      Mod+Home { focus-column-first; }
      Mod+End  { focus-column-last; }
      Mod+Ctrl+Home { move-column-to-first; }
      Mod+Ctrl+End  { move-column-to-last; }

      Mod+Page_Down      { focus-workspace-down; }
      Mod+Page_Up        { focus-workspace-up; }
      Mod+I              { focus-workspace-up; }
      Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
      Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
      Mod+Ctrl+I         { move-column-to-workspace-up; }

      Mod+Shift+Page_Down { move-workspace-down; }
      Mod+Shift+Page_Up   { move-workspace-up; }
      Mod+Shift+I         { move-workspace-up; }

      Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
      Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
      Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
      Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

      Mod+WheelScrollRight      { focus-column-right; }
      Mod+WheelScrollLeft       { focus-column-left; }
      Mod+Ctrl+WheelScrollRight { move-column-right; }
      Mod+Ctrl+WheelScrollLeft  { move-column-left; }

      Mod+Shift+WheelScrollDown      { focus-column-right; }
      Mod+Shift+WheelScrollUp        { focus-column-left; }
      Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
      Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

      Mod+BracketLeft  { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }
      Mod+Comma  { consume-window-into-column; }
      Mod+Period { expel-window-from-column; }

      Mod+Ctrl+W       { switch-preset-column-width; }
      Mod+Ctrl+Shift+W { switch-preset-column-width-back; }
      Mod+Shift+W      { toggle-column-tabbed-display; }

      Mod+Ctrl+Shift+R { switch-preset-window-height; }
      Mod+Ctrl+R       { reset-window-height; }

      Mod+F      { maximize-column; }
      Mod+Ctrl+F { expand-column-to-available-width; }

      Mod+C      { center-column; }
      Mod+Ctrl+C { center-visible-columns; }

      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }

      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }

      Mod+O repeat=false { toggle-overview; }

      Print      { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print  { screenshot-window; }

      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

      Mod+Shift+E     { quit; }
      Ctrl+Alt+Delete { quit; }

      Mod+Shift+P { power-off-monitors; }
  }
''
