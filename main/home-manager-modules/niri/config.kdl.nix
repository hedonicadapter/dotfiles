{outputs, ...}: let
  p = outputs.palette;
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

  output "eDP-1" {
      mode "2150x1440@144"
      scale 1
      position x=0 y=0
  }

  output "HDMI-A-1" {
      mode "2560x1440@119.998"
      scale 2.0
      variable-refresh-rate // on-demand=true
      focus-at-startup
  }

  layout {
      gaps 16
      center-focused-column "never"
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

  spawn-sh-at-startup "bash ~/.config/niri/auto-start.sh"
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

  animations {
      // Pixelate — github.com/Xansidev/nirimation
      // Curve must stay linear; shader drives pixel size off niri_clamped_progress
      window-open {
          duration-ms 700
          curve "linear"
          custom-shader r"
            vec4 pixelate_open(vec3 coords_geo, vec3 size_geo) {
                if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                    return vec4(0.0);
                }
                float progress = niri_clamped_progress;
                float border_width = 0.008;
                vec2 coords = coords_geo.xy;
                bool in_border = coords.x < border_width || coords.x > (1.0 - border_width) ||
                                coords.y < border_width || coords.y > (1.0 - border_width);
                // Pixelate inner content only, leave border crisp
                if (!in_border) {
                    float pixel_size = (1.0 - progress) * 0.1;
                    if (pixel_size > 0.0) {
                        coords = floor(coords / pixel_size) * pixel_size + pixel_size * 0.5;
                    }
                    coords = clamp(coords, border_width, 1.0 - border_width);
                }
                vec3 new_coords = vec3(coords, 1.0);
                vec3 coords_tex = niri_geo_to_tex * new_coords;
                vec4 color = texture2D(niri_tex, coords_tex.st);
                color.a *= progress;
                return color;
            }

            vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                return pixelate_open(coords_geo, size_geo);
            }
          "
      }

      window-close {
          duration-ms 700
          curve "linear"
          custom-shader r"
            vec4 pixelate_close(vec3 coords_geo, vec3 size_geo) {
                if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                    return vec4(0.0);
                }
                float progress = niri_clamped_progress;
                float border_width = 0.008;
                vec2 coords = coords_geo.xy;
                bool in_border = coords.x < border_width || coords.x > (1.0 - border_width) ||
                                coords.y < border_width || coords.y > (1.0 - border_width);
                // Pixelate inner content only, leave border crisp
                if (!in_border) {
                    float pixel_size = progress * 0.1;
                    if (pixel_size > 0.0) {
                        coords = floor(coords / pixel_size) * pixel_size + pixel_size * 0.5;
                    }
                    coords = clamp(coords, border_width, 1.0 - border_width);
                }
                vec3 new_coords = vec3(coords, 1.0);
                vec3 coords_tex = niri_geo_to_tex * new_coords;
                vec4 color = texture2D(niri_tex, coords_tex.st);
                color.a *= (1.0 - progress);
                return color;
            }

            vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                return pixelate_close(coords_geo, size_geo);
            }
          "
      }
  }

  window-rule {
      match is-active=false
      exclude app-id="^mpv$"
      opacity 0.6
  }

  // Blur+noise behind all windows; shows through the opacity rule above.
  // Keeps default xray — non-xray blur breaks the open/close shaders.
  window-rule {
      exclude app-id="^mpv$"
      background-effect {
          blur true
          noise 0.05
      }
  }

  window-rule {
      match app-id="popup"
      open-floating true
  }

  window-rule {
      match title="^Picture-in-Picture$"
      open-floating true
  }

  window-rule {
      match at-startup=true app-id="obsidian"
      open-focused false
  }

  binds {
      Mod+Shift+Slash { show-hotkey-overlay; }

      Mod+R { spawn "wlr-which-key-run"; }
      Mod+B { spawn "wlr-which-key-browser"; }
      Mod+D { spawn "wlr-which-key-directories"; }
      Mod+Q { spawn "wlr-which-key-query"; }
      Mod+U { spawn "wlr-which-key-utility"; }
      Mod+S { spawn "wlr-which-key-system"; }

      Mod+V { spawn "hints"; }
      Mod+T hotkey-overlay-title="Open a Terminal: kitty" { spawn "kitty"; }

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

      Mod+Shift+H     { move-column-left-or-to-monitor-left; }
      Mod+Shift+J     { move-window-down; }
      Mod+Shift+K     { move-window-up; }
      Mod+Shift+L     { move-column-right-or-to-monitor-right; }
      Mod+Shift+Left  { move-column-left-or-to-monitor-left; }
      Mod+Shift+Down  { move-window-down; }
      Mod+Shift+Up    { move-window-up; }
      Mod+Shift+Right { move-column-right-or-to-monitor-right; }

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

      XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
      XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
      XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
      XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

      XF86AudioPlay  allow-when-locked=true { spawn-sh "playerctl play-pause"; }
      XF86AudioPause allow-when-locked=true { spawn-sh "playerctl play-pause"; }
      XF86AudioStop  allow-when-locked=true { spawn-sh "playerctl stop"; }
      XF86AudioPrev  allow-when-locked=true { spawn-sh "playerctl previous"; }
      XF86AudioNext  allow-when-locked=true { spawn-sh "playerctl next"; }

      XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
      XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

      Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

      Mod+Shift+E     { quit; }
      Ctrl+Alt+Delete { quit; }

      Mod+Shift+P { power-off-monitors; }
  }
''
