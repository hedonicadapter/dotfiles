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
    # $editor = neovide
    $fileManager = nautilus
    $menu = tofi-run
    $mail = xdg-open https://mail.google.com
    $browser = zen-beta
    $music = spotify

    exec-once=[workspace 1 silent] $terminal --detach --hold -e nvim ~/big-todo.md
    exec-once=[workspace 1 silent] $browser
    exec-once=[workspace 5 silent] obsidian

    env = AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1

    env = XCURSOR_SIZE,100
    env = XCURSOR_THEME,rah
    env = HYPRCURSOR_THEME,rah
    env = HYPRCURSOR_SIZE,100

    env = QT_QPA_PLATFORMTHEME,qt6ct # change to qt6ct if you have that
    env = ELECTRON_OZONE_PLATFORM_HINT=auto
    env = GSK_RENDERER,ngl # error 71 gtk

    monitor=eDP-1, 2150x1440,auto,1
    monitor=HDMI-A-1, preferred,2160x0,0.75

    # Xenit
    monitor=DP-3, preferred,2560x-1440,1
    monitor=DP-4, preferred,5120x-1440,1
    monitor=DP-1, preferred,auto,1

    # for AlfredoSequeida/hints
    device {
      name = ydotoold-virtual-device-1
      accel_profile = flat
    }

    xwayland {
      force_zero_scaling = true
      use_nearest_neighbor = false
    }

    plugin {
        split-monitor-workspaces {
            count = 4
            enable_notifications = 0
        }

        #  TODO: marked broken
        # hyprfocus {
        #     enabled = yes
        #     animate_floating = yes
        #     animate_workspacechange = yes
        #     focus_animation = flash
        #
        #     bezier = bezIn, 0.5,0.0,1.0,0.5
        #     bezier = bezOut, 0.0,0.5,0.5,1.0
        #     bezier = overshot, 0.05, 0.9, 0.1, 1.05
        #     bezier = smoothOut, 0.36, 0, 0.66, -0.56
        #     bezier = smoothIn, 0.25, 1, 0.5, 1
        #     bezier = realsmooth, 0.28,0.29,.69,1.08
        #
        #     flash {
        #         flash_opacity = 0.95
        #         in_bezier = realsmooth
        #         in_speed = 0.5
        #         out_bezier = realsmooth
        #         out_speed = 3
        #     }
        # }
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

        repeat_rate = 20
        repeat_delay = 200

        touchpad {
            natural_scroll = true
        }
    }

    general {
        gaps_in = 8
        gaps_out = 16
        border_size = 1
        col.active_border = rgb(${processColor outputs.palette.base04})
        col.inactive_border = rgb(${processColor outputs.palette.base03})

        layout = dwindle

        allow_tearing = false
        no_focus_fallback = true
    }

    debug {
      damage_tracking = 0
    }

    decoration {
        dim_inactive = true
        dim_strength = 0.3

        rounding = 0

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

        animation = layers, 1, 0.5, myBezier
        animation = fade, 1, 0.5, myBezier
        animation = windows, 1, 0.5, myBezier, slide
        animation = windowsOut, 1, 0.5, myBezier, slide
        animation = workspaces, 1, 0.5, myBezier

        # animation = border, 1, 3.5, myBezier
        # animation = borderangle, 1, 11.5, easeOutBack
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
        focus_on_activate = false
        animate_manual_resizes = true
        new_window_takes_over_fullscreen = 2
        initial_workspace_tracking = 0
        vfr = true
        # vrr = 2
    }

    opengl {
        nvidia_anti_flicker = false
    }

    render {
        direct_scanout = 2
    }

    binds {
        workspace_center_on = 1
    }

    workspace=1,defaultName:main
    workspace=2,defaultName:misc
    workspace=3,defaultName:misc
    workspace=4,defaultName:misc
    workspace=5,defaultName:misc
    workspace=6,defaultName:misc
    workspace=7,defaultName:misc
    workspace=8,defaultName:misc
    workspace=9,defaultName:misc
    workspace=10,defaultName:misc

    windowrulev2 = bordersize 0, floating:0, onworkspace:w[tv1]
    windowrulev2 = rounding 0, floating:0, onworkspace:w[tv1]
    windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
    windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

    windowrule = float, class:^(.*popup.*)$
    windowrule = center, class:^(.*popup.*)$
    windowrule = stayfocused, class:^(.*popup.*)$

    bezier=easeOutQuart, 0.25,1,0.5,1
    animation=windows, 1, 3.5, easeOutQuart, popin
    animation=workspaces, 1, 3.5, easeOutQuart, slide

    $mainMod = SUPER

    # Which-key menus (wlr-which-key) — globally available on PATH, shared with niri.
    # Menu contents live in home-manager-modules/wlr-which-key/menus.nix
    bind = $mainMod, R, exec, wlr-which-key-run
    bind = $mainMod, B, exec, wlr-which-key-browser
    bind = $mainMod, D, exec, wlr-which-key-directories
    bind = $mainMod, Q, exec, wlr-which-key-query
    bind = $mainMod, U, exec, wlr-which-key-utility
    bind = $mainMod, S, exec, wlr-which-key-system

    bind = SUPER, V, exec, hints
    # bind = SUPER, Y, exec, hints --mode scroll

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
