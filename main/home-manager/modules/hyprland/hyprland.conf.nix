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
    exec-once = bash ~/.config/hypr/auto-float-unfloat.sh

    $terminal = kitty
    $editor = neovide
    $fileManager = nautilus
    $menu = tofi-run
    $browser = firefox-beta
    $music = spotify

    exec-once=[split-workspace 5 silent] $browser && $editor
    exec-once=[split-workspace 6 silent] obsidian
    exec-once=[split-workspace 1 silent] vesktop
    exec-once=[split-workspace 1 silent] $music

    # env = AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1
    env = XCURSOR_SIZE,24
    env = XCURSOR_THEME,Oxygen-Neon
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

    $mainMod = SUPER
    $resetSubmap = hyprctl dispatch submap reset
    $timeoutSubmap = sleep 1 && hyprctl dispatch submap reset

    $appQuery = tofi-run | xargs hyprctl dispatch exec --
    $nixQuery = PATH= tofi-run | xargs -I {} xdg-open "https://search.nixos.org/packages?query={}"
    $googleQuery = PATH= tofi-run | xargs -I {} xdg-open "https://www.google.com/search?q={}"
    $protonDbQuery = PATH= tofi-run | xargs -I {} xdg-open "https://www.protondb.com/search?q={}"
    $nixOptionsQuery = PATH= tofi-run | xargs -I {} xdg-open "https://search.nixos.org/options?query={}"
    $homeManagerQuery = PATH= tofi-run | xargs -I {} xdg-open "https://home-manager-options.extranix.com/?query={}"
    $clipboardHistoryQuery = cliphist list | tofi | cliphist decode | wl-copy

    # Run
    bind = $mainMod, R, submap, run
    bind = $mainMod, R, exec, $timeoutSubmap
    submap = run
    bindd = , T, TERMINAL, exec, $terminal & $resetSubmap
    bindd = , E, NEOVIM, exec, $editor & $resetSubmap
    bindd = , M, MUSIC, exec, $music & $resetSubmap
    bindd = , D, DISCORD, exec, vesktop & $resetSubmap
    bindd = , S, M0XYY, exec, $terminal 'streamlink twitch.tv/m0xyy 720p60 --player mpv --twitch-low-latency & TERM=xterm-kitty twt' & $resetSubmap
    bindd = , Y, YOUTUBE, exec, $terminal pipe-viewer & $resetSubmap
    bind = , escape, submap, reset
    submap = reset

    # Browser submap
    bind = $mainMod, B, submap, browser
    bind = $mainMod, B, exec, $timeoutSubmap
    submap = browser
    bindd = , B, DEFAULT, exec, $browser & $resetSubmap
    bindd = , F, FIREFOX, exec, firefox-beta & $resetSubmap
    bindd = , E, EDGE, exec, microsoft-edge & $resetSubmap
    bind = , escape, submap, reset
    submap = reset

    # Files submap
    bind = $mainMod, F, submap, files
    bind = $mainMod, F, exec, $timeoutSubmap
    submap = files
    bindd = , F, DEFAULT, exec, $fileManager & $resetSubmap
    bindd = , T, TEMP, exec, $fileManager ~/Documents/temp & $resetSubmap
    bindd = , D, DOWNLOADS, exec, $fileManager ~/Downloads & $resetSubmap
    bind = , escape, submap, reset
    submap = reset

    # Query submap
    bind = $mainMod, Q, submap, query
    bind = $mainMod, Q, exec, $timeoutSubmap
    submap = query
    bindd = , A, APPS, exec, $appQuery & $resetSubmap
    bindd = , N, NIXPKGS, exec, $nixQuery & $resetSubmap
    bindd = , G, GOOGLE, exec, $googleQuery & $resetSubmap
    bindd = , P, PROTONDB, exec, $protonDbQuery & $resetSubmap
    bindd = , O, NIX OPTIONS, exec, $nixOptionsQuery & $resetSubmap
    bindd = , H, HOME MANAGER OPTIONS, exec, $homeManagerQuery & $resetSubmap
    bindd = , C, CLIPBOARD, exec, $clipboardHistoryQuery & $resetSubmap
    bind = , escape, submap, reset
    submap = reset

    # Utility submap
    bind = $mainMod, U, submap, util
    bind = $mainMod, U, exec, $timeoutSubmap
    submap = util
    bindd = , P, PRINT-SCREEN, exec, grim -g "$(slurp)" - | swappy -f - | wl-copy & $resetSubmap
    bindd = , C, COLOR PICKER, exec, hyprpicker -a & $resetSubmap
    bindd = , R, SPEED READER, exec, $terminal bash ~/.config/hypr/speed-read.sh & $resetSubmap
    bindd = , E, EMOJI PICKER, exec, rofimoji --selector tofi & $resetSubmap
    bind = , escape, submap, reset
    submap = reset

    # System submap
    bind = $mainMod, S, submap, system
    bind = $mainMod, S, exec, $timeoutSubmap
    submap = system
    bindd = , R, RELOAD SHELL, exec, ags quit; ags run & $resetSubmap
    bindd = , Z, TOGGLE ZEN MODE, exec, ags -r "zenable = !zenable" & $resetSubmap # toggle zen mode
    bindd = , P, POWER MENU, exec, ags -r "App.toggleWindow('powermenu')" & $resetSubmap

    # Audio
    binddl = , AP, PLAY/PAUSE, exec, playerctl play-pause & $resetSubmap
    binddl = , AL, NEXT, exec, playerctl next & $resetSubmap
    binddl = , AH, PREVIOUS, exec, playerctl previous & $resetSubmap

    binddle = , AK, VOL UP, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+ & $resetSubmap
    binddle = , AJ, VOL DOWN, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%- & $resetSubmap

    binddle = , ASM, MUTE/UNMUTE OUT, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle & $resetSubmap
    bindd = , AMM, MUTE/UNMUTE IN, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle & $resetSubmap

    bindd = , AS, AUDIO SETTINGS, exec, easyeffects & $resetSubmap # TODO: replace wiwth AGS later

    # Display
    binddle = , DK, BRIGHTNESS UP, exec, brightnessctl set +10% & $resetSubmap
    binddle = , DJ, BRIGHTNESS DOWN, exec, brightnessctl set 10%- & $resetSubmap
    bind = , escape, submap, reset
    submap = reset

    bind = $mainMod, W, killactive,
    bind = $mainMod SHIFT, F, togglefloating,
    bind = $mainMod, M, fullscreen,1

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

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow
  '';
in
  config
