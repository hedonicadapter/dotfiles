{
  outputs,
  lib,
  ...
}: let
  config = let
    processColor = color: let
      # Remove the first character and convert to lowercase
      processedColor = lib.toLower (builtins.substring 1 6 (builtins.toString color));
    in
      processedColor;
  in ''
    exec-once = bash ~/.config/hypr/auto-start.sh
    # exec-once = bash ~/.config/hypr/auto-float-unfloat.sh

    $terminal = kitty
    $editor = neovide
    $fileManager = nautilus
    $menu = tofi-run
    $browser = firefox-beta
    $music = spotify

    exec-once=[split-workspace 5 silent] $browser && $editor
    exec-once=[split-workspace 6 silent] obsidian
    exec-once=[split-workspace 1 silent] DiscordCanary
    exec-once=[split-workspace 1 silent] $music

    # env = AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1
    env = XCURSOR_SIZE,24
    env = XCURSOR_THEME,Bibata_Ghost
    env = QT_QPA_PLATFORMTHEME,qt6ct # change to qt6ct if you have that
    env = ELECTRON_OZONE_PLATFORM_HINT=auto
    env = GSK_RENDERER,ngl # error 71 gtk

    monitor=eDP-1, 2150x1440,auto,1
    monitor=HDMI-A-1, preferred,2160x0,1
    xwayland {
      force_zero_scaling = true
      use_nearest_neighbor = false
    }


    plugin {
        split-monitor-workspaces {
            count = 4
            enable_notifications = 0
        }
    }

    input {
        kb_layout = se
        kb_variant =
        kb_model =
        kb_options =
        kb_rules =

        accel_profile = adaptive
        # accel_profile = custom 4 0.3 0.4 0.75 0.9 0.95 1.0
        # sensitivity = 1.0

        follow_mouse = 1

        touchpad {
            natural_scroll = true
        }
    }

    general {
        gaps_in = 3
        gaps_out = 6
        border_size = 0

        layout = dwindle

        allow_tearing = false
        no_focus_fallback = true
    }

    decoration {
        dim_inactive = true
        dim_strength = 0.35

        rounding = 1

        blur {
            enabled = false
        }

        shadow {
            enabled = false
        }
    }

    animations {
        enabled = true
        bezier = myBezier, 0, 0, 0.58, 1
        bezier = easeOutBack, 0.34, 1.56, 0.64, 1

        animation = windows, 1, 7, myBezier, slide
        animation = windowsOut, 1, 5.5, myBezier, slide

        animation = border, 1, 4.5, myBezier
        animation = borderangle, 1, 12.5, easeOutBack

        animation = fade, 1, 2.5, myBezier
        animation = workspaces, 1, 6, myBezier
    }

    dwindle {
        preserve_split = true # you probably want this
    }

    gestures {
        workspace_swipe = false
    }

    misc {
        force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true
        disable_splash_rendering = true
        focus_on_activate = true
        animate_manual_resizes = true
        new_window_takes_over_fullscreen = 2
        initial_workspace_tracking = 2
        vfr = true
        # vrr = 2
    }

    opengl {
        nvidia_anti_flicker = false
    }

    binds {
        workspace_center_on = 1
    }

    workspace = w[tv1], gapsout:0, gapsin:0
    workspace = f[1], gapsout:0, gapsin:0
    windowrulev2 = bordersize 0, floating:0, onworkspace:w[tv1]
    windowrulev2 = rounding 0, floating:0, onworkspace:w[tv1]
    windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
    windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

    # windowrulev2 = suppressevent maximize, class:.* # You'll probably like this.
    windowrulev2 = bordercolor rgba(FFFFFF80) rgba(FFFFFF26) 50deg,fullscreen:1
    windowrulev2 = size 70% 80%, onworkspace:w[1]
    windowrulev2 = center, onworkspace:w[1]
    windowrulev2 = float, onworkspace:w[1]
    windowrulev2 = tile, onworkspace:w[2-8]

    windowrule = float, ^(.*popup.*)$
    windowrule = stayfocused, ^(.*popup.*)$

    bezier=easeOutQuart, 0.25,1,0.5,1
    animation=windows, 1, 3.5, easeOutQuart, popin
    animation=workspaces, 1, 3.5, easeOutQuart, slide

    # layerrule=ignorealpha[0.75],bar-0

    $mainMod = SUPER

    bind=$mainMod, Print, exec, grim -g "$(slurp)" - | swappy -f - | wl-copy

    bind=CTRL SHIFT, R,  exec, ags quit; ags run

    bind = $mainMod SHIFT, C, exec, hyprpicker -a
    bind = $mainMod, C, exec, cliphist list | tofi | cliphist decode | wl-copy

    # launcher
    # bind = $mainMod, O&B, exec, xdg-open about:blank # Open Browser
    # bind = $mainMod, O&S, exec, spotify # Open Spotify
    # bind = $mainMod, O&L, exec, lutris # Open Lutris
    # bind = $mainMod, O&D, exec, DiscordCanary # Open Discord
    # bind = $mainMod, O&O, exec, obsidian # Open Obsidian

    bind = $mainMod, T, exec, $terminal
    bind = $mainMod, N, exec, $editor
    bind = $mainMod, E, exec, $fileManager
    bind = $mainMod, R, exec, tofi-run | xargs hyprctl dispatch exec --
    bind = $mainMod SHIFT, S, exec, $terminal bash ~/.config/hypr/speed-read.sh
    bind = $mainMod, period, exec, rofimoji --selector tofi

    bind = $mainMod, Q, killactive,
    bind = $mainMod, Z, exec, ags -r "zenable = !zenable" # toggle zen mode
    bind = $mainMod, escape, exec, ags -r "App.toggleWindow('powermenu')"
    bind = $mainMod, F, togglefloating,
    bind = $mainMod, M, fullscreen,1

    bind = $mainMod, P, exec, nautilus ~/Documents/temp
    bind = $mainMod, D, exec, nautilus ~/Downloads
    bind = $mainMod, B, exec, $browser
    bind = $mainMod, S, exec, $music

    bind = $mainMod, H, movefocus, l
    bind = $mainMod, L, movefocus, r
    bind = $mainMod, K, movefocus, u
    bind = $mainMod, J, movefocus, d

    bind = $mainMod, up, cyclenext

    bind = $mainMod SHIFT, H, movewindow, l
    bind = $mainMod SHIFT, L, movewindow, r
    bind = $mainMod SHIFT, K, movewindow, u
    bind = $mainMod SHIFT, J, movewindow, d

    binde = $mainMod Control_L, H, resizeactive, -30 0
    binde = $mainMod Control_L, L, resizeactive, 30 0
    binde = $mainMod Control_L, K, resizeactive, 0 -30
    binde = $mainMod Control_L, J, resizeactive, 0 30

    bind = $mainMod, 1, split-workspace, 1
    bind = $mainMod, 2, split-workspace, 2
    bind = $mainMod, 3, split-workspace, 3
    bind = $mainMod, 4, split-workspace, 4

    bind = $mainMod SHIFT, 1, split-movetoworkspace, 1
    bind = $mainMod SHIFT, 2, split-movetoworkspace, 2
    bind = $mainMod SHIFT, 3, split-movetoworkspace, 3
    bind = $mainMod SHIFT, 4, split-movetoworkspace, 4
    bind = $mainMod SHIFT, 5, split-movetoworkspace, 5
    bind = $mainMod SHIFT, 6, split-movetoworkspace, 6
    bind = $mainMod SHIFT, 7, split-movetoworkspace, 7
    bind = $mainMod SHIFT, 8, split-movetoworkspace, 8
    bind = $mainMod SHIFT, 9, split-movetoworkspace, 9
    bind = $mainMod SHIFT, 0, split-movetoworkspace, 10

    # Example special workspace (scratchpad)
    # bind = $mainMod SHIFT, S, movetoworkspace, special:magic

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    # l -> do stuff even when locked
    # e -> repeats when key is held
    bindle=, XF86Search, exec, launchpad

    # Audio
    bindl=, XF86AudioPlay, exec, playerctl play-pause # the stupid key is called play , but it toggles
    bindl=, XF86AudioNext, exec, playerctl next
    bindl=, XF86AudioPrev, exec, playerctl previous

    bindle=, F1, exec, pactl list short sinks | awk '{print $1}' | xargs -I{} pactl set-sink-mute {} toggle
    bindle=, F2, exec, pactl list short sinks | awk '{print $1}' | xargs -I{} pactl set-sink-volume {} -10%
    bindle=, F3, exec, pactl list short sinks | awk '{print $1}' | xargs -I{} pactl set-sink-volume {} +10%

    bind = $mainMod, s, exec, bash ~/.config/hypr/toggle-mic.sh
    # bindr = $mainMod, s, exec, amixer set Capture nocap doesnt work well

    bind = $mainMod, A, exec, easyeffects

    # Brightness
    bindle = , F6, exec, brightnessctl set +10%
    bindle = , F5, exec, brightnessctl set 10%-


    bind=$mainMod,Backspace,exec,hyprctl keyword cursor:inactive_timeout 0; hyprctl keyword cursor:hide_on_key_press false; hyprctl dispatch submap cursor

    submap=cursor

    binde=,j,exec,wlrctl pointer move 0 10
    binde=,k,exec,wlrctl pointer move 0 -10
    binde=,l,exec,wlrctl pointer move 10 0
    binde=,h,exec,wlrctl pointer move -10 0

    bind=,m,exec,wlrctl pointer click left
    bind=,comma,exec,wlrctl pointer click middle
    bind=,period,exec,wlrctl pointer click right

    binde=,e,exec,wlrctl pointer scroll 10 0
    binde=,r,exec,wlrctl pointer scroll -10 0
    binde=,d,exec,wlrctl pointer scroll 0 -10
    binde=,f,exec,wlrctl pointer scroll 0 10

    bind=,escape,exec,hyprctl keyword cursor:inactive_timeout 3; hyprctl keyword cursor:hide_on_key_press true; hyprctl dispatch submap reset

    submap = reset

  '';
in
  config
