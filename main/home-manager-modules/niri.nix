{
    pkgs,
  ...
}: {
  systemd.user.services.niri.enableDefaultPath = false;

    home.packages = with pkgs; [
        xwayland-satellite
    ];

  home.file = {
    ".config/niri/config.kdl" = {
      text = ''
        // Minimal starter config for migrating from Hyprland to Niri.
        // Keep this small and stable first, then grow it once daily workflow is solid.

        input {
            mod-key "Super"

            keyboard {
                xkb {
                    layout "se"
                }

                repeat-rate 20
                repeat-delay 200
            }

            touchpad {
                natural-scroll
            }

            mouse {
                accel-profile "adaptive"
            }

            focus-follows-mouse max-scroll-amount="0%"
        }

        output "eDP-1" {
            mode "2150x1440"
        }

        output "HDMI-A-1" {
            scale 0.75
            position x=2160 y=0
        }

        layout {
            gaps 16
            default-column-width { proportion 0.5; }

            border {
                off
            }

            focus-ring {
                width 1
            }
        }

        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

        binds {
            Mod+T { spawn "kitty"; }
            Mod+D { spawn "tofi-run"; }
            Mod+B { spawn "zen-beta"; }

            Mod+Q repeat=false { close-window; }
            Mod+Shift+E { quit; }

            Mod+H { focus-column-left; }
            Mod+J { focus-window-down; }
            Mod+K { focus-window-up; }
            Mod+L { focus-column-right; }

            Mod+Ctrl+H { move-column-left; }
            Mod+Ctrl+J { move-window-down; }
            Mod+Ctrl+K { move-window-up; }
            Mod+Ctrl+L { move-column-right; }

            Mod+F { maximize-column; }
            Mod+Shift+F { fullscreen-window; }
            Mod+V { toggle-window-floating; }

            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+7 { focus-workspace 7; }
            Mod+8 { focus-workspace 8; }
            Mod+9 { focus-workspace 9; }

            Mod+Ctrl+1 { move-column-to-workspace 1; }
            Mod+Ctrl+2 { move-column-to-workspace 2; }
            Mod+Ctrl+3 { move-column-to-workspace 3; }
            Mod+Ctrl+4 { move-column-to-workspace 4; }
            Mod+Ctrl+5 { move-column-to-workspace 5; }
            Mod+Ctrl+6 { move-column-to-workspace 6; }
            Mod+Ctrl+7 { move-column-to-workspace 7; }
            Mod+Ctrl+8 { move-column-to-workspace 8; }
            Mod+Ctrl+9 { move-column-to-workspace 9; }

            XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
            XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
            XF86AudioMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
            XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

            XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
            XF86AudioPause allow-when-locked=true { spawn-sh "playerctl play-pause"; }
            XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous"; }
            XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }

            XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
            XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }

            Print { screenshot; }
            Ctrl+Print { screenshot-screen; }
            Alt+Print { screenshot-window; }
        }
      '';
    };
  };
}