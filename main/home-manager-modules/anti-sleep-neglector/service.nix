# lotta claude.ai juice on here cause idk how to shell script
{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
with lib; let
  removeHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;

  shaderDir = "${config.home.homeDirectory}/.config/anti-sleep-neglector/shaders";

  # hyprctl lives in the hyprland package
  hyprlandPkg = config.wayland.windowManager.hyprland.package or pkgs.hyprland;

  # Defines refresh_circadian_vars, which (re)reads the period times published by
  # anti-sleep-neglector.service into the systemd user environment. Callers must
  # invoke it — long-running consumers re-invoke it so values don't go stale.
  circadianVars = ''
    function get_circadian_period() {
        if [ -z "$1" ]; then
            echo "Error: No period specified" >&2
            return 1
        fi

        local value
        value=$(systemctl --user show-environment | grep "^$1=" | cut -d= -f2-)

        if [ -z "$value" ]; then
            # Provide default values if the environment variable is not set
            case "$1" in
                FIRST_LIGHT)  value="06:00:00" ;;
                DAWN)         value="06:30:00" ;;
                SUNRISE)      value="07:00:00" ;;
                SOLAR_NOON)   value="12:00:00" ;;
                SUNSET)       value="19:00:00" ;;
                LAST_LIGHT)   value="20:00:00" ;;
                *)
                    echo "Error: Unknown period $1" >&2
                    return 1
                    ;;
            esac
            echo "Warning: Using default value for $1: $value" >&2
        fi

        echo "$value"
    }

    function refresh_circadian_vars() {
        FIRST_LIGHT=$(get_circadian_period FIRST_LIGHT)
        DAWN=$(get_circadian_period DAWN)
        SUNRISE=$(get_circadian_period SUNRISE)
        SOLAR_NOON=$(get_circadian_period SOLAR_NOON)
        SUNSET=$(get_circadian_period SUNSET)
        LAST_LIGHT=$(get_circadian_period LAST_LIGHT)
        LATITUDE=$(systemctl --user show-environment | grep "^LATITUDE=" | cut -d= -f2-)
        LONGITUDE=$(systemctl --user show-environment | grep "^LONGITUDE=" | cut -d= -f2-)
    }
  '';
in {
  options = {
    services.anti-sleep-neglector = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable anti-sleep-neglector protocols.
        '';
      };
    };

    services.anti-sleep-neglector-monitor = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable anti-sleep-neglector monitor automatic brightness control.
        '';
      };

      interval = mkOption {
        type = types.str;
        default = "1m";
        description = ''
          How often to recalculate monitor brightness (systemd time span).
        '';
      };

      nightBrightness = mkOption {
        type = types.int;
        default = 20;
        description = "Backlight percentage at night.";
      };

      dayBrightness = mkOption {
        type = types.int;
        default = 100;
        description = "Backlight percentage at solar noon.";
      };
    };

    services.anti-sleep-neglector-gamma = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable anti-sleep-neglector monitor automatic gamma control.
        '';
      };

      periods = mkOption {
        type = types.submodule {
          options = {
            dawn = mkOption {
              type = types.float;
              default = 4000.0;
              description = "Brightness setting for dawn period";
            };
            first_light = mkOption {
              type = types.float;
              default = 4000.0;
              description = "Brightness setting for first light period";
            };
            night = mkOption {
              type = types.float;
              default = 2500.0;
              description = "Brightness setting for night period";
            };
            solar_noon = mkOption {
              type = types.float;
              default = 7000.0;
              description = "Brightness setting for solar noon period";
            };
            sunrise = mkOption {
              type = types.float;
              default = 5500.0;
              description = "Brightness setting for sunrise period";
            };
            sunset = mkOption {
              type = types.float;
              default = 3500.0;
              description = "Brightness setting for sunset period";
            };
          };
        };
        default = {
          dawn = 4000.0;
          first_light = 4000.0;
          night = 2500.0;
          solar_noon = 7000.0;
          sunrise = 5500.0;
          sunset = 3500.0;
        };
        description = "Brightness periods configuration";
      };

      # Gamma, not backlight: dims displays brightnessctl can't reach (HDMI, projectors)
      brightness = mkOption {
        type = types.submodule {
          options =
            mapAttrs (period: default:
              mkOption {
                type = types.ints.between 10 200;
                inherit default;
                description = "sunsetr gamma percentage for the ${period} period (100 = unchanged). niri only.";
              }) {
              dawn = 95;
              first_light = 90;
              night = 85;
              solar_noon = 100;
              sunrise = 100;
              sunset = 95;
            };
        };
        default = {};
        description = "Per-period display brightness applied by sunsetr under niri";
      };

      crt-effect = mkOption {
        type = types.submodule {
          options = {
            glowStrength = mkOption {
              type = types.float;
              default = 0.12;
            };
            glowRadius = mkOption {
              type = types.float;
              default = 0.0005;
            };
            scanlineFrequency = mkOption {
              type = types.float;
              default = 1600.0;
            };
            scanlineIntensity = mkOption {
              type = types.float;
              default = 0.03;
            };
            curvatureStrength = mkOption {
              type = types.float;
              default = 0.1;
            };
            brightness = mkOption {
              type = types.float;
              default = 0.0;
            };
            contrast = mkOption {
              type = types.float;
              default = 1.0;
            };
          };
        };
        default = {};
      };
    };

    services.anti-sleep-neglector-lifx = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to make sunsetr follow a LIFX group (niri only): bulb kelvin sets the
          colour temperature, bulb brightness the dimming. Per-period presets resume when
          the bulbs stop answering. Needs UDP `port` open in the NixOS firewall.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "home";
        description = "LIFX group label to follow (case-insensitive).";
      };

      interval = mkOption {
        type = types.ints.positive;
        default = 5;
        description = "Seconds between polls.";
      };

      brightnessFloor = mkOption {
        type = types.ints.between 10 100;
        default = 70;
        description = "Display gamma % with the group at 0% brightness; scales linearly to 100% at full.";
      };

      port = mkOption {
        type = types.port;
        default = 56700;
        description = "Local UDP port bulbs reply to.";
      };
    };

    services.anti-sleep-neglector-wallpaper = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable anti-sleep-neglector selecting wallpapers by brightness and circadian period.
        '';
      };
      wallpapersDir = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/Pictures/wallpapers";
        description = ''
          Your wallpaper directory. Images and GIFs go through swww, videos
          through mpvpaper.
        '';
      };
      cycleInterval = mkOption {
        type = types.ints.positive;
        default = 3600;
        description = ''
          Seconds between wallpaper changes within the current circadian period.
        '';
      };
    };
  };

  config = mkMerge [
    (mkIf config.services.anti-sleep-neglector.enable {
      systemd.user.services."anti-sleep-neglector" = {
        Unit = {
          Description = "Run anti sleep neglector protocol";
        };

        Service = {
          Type = "oneshot";
          # Stay active so dependents can Requires= this unit without re-running it
          RemainAfterExit = true;
          ExecStart = "${pkgs.writeShellScript "set_circadian_vars" ''
            #!/usr/bin/env bash
            PATH=$PATH:${lib.makeBinPath [
              pkgs.coreutils
              pkgs.gawk
              pkgs.gnugrep
              pkgs.jq
              pkgs.procps
              pkgs.curlMinimal
              pkgs.bc
              pkgs.systemd
            ]}

            set -x
            exec &> /tmp/anti-sleep-neglector.log

            get_season() {
                local month=$(date +%m)
                local day=$(date +%d)
                local hemisphere=$1

                if [ "$hemisphere" = "north" ]; then
                    if [ "$month" -ge 3 ] && [ "$month" -le 5 ]; then
                        echo "spring"
                    elif [ "$month" -ge 6 ] && [ "$month" -le 8 ]; then
                        echo "summer"
                    elif [ "$month" -ge 9 ] && [ "$month" -le 11 ]; then
                        echo "autumn"
                    else
                        echo "winter"
                    fi
                else
                    if [ "$month" -ge 3 ] && [ "$month" -le 5 ]; then
                        echo "autumn"
                    elif [ "$month" -ge 6 ] && [ "$month" -le 8 ]; then
                        echo "winter"
                    elif [ "$month" -ge 9 ] && [ "$month" -le 11 ]; then
                        echo "spring"
                    else
                        echo "summer"
                    fi
                fi
            }

            get_default_times() {
                local latitude=$1
                local season=$2

                local lat_abs=$(echo $latitude | awk '{print sqrt($1*$1)}')

                if (( $(echo "$lat_abs < 23" | bc -l) )); then
                    echo "05:30:00 06:00:00 06:30:00 12:00:00 18:00:00 18:30:00"
                elif (( $(echo "$lat_abs < 45" | bc -l) )); then
                    case $season in
                        "summer")
                            echo "04:30:00 05:00:00 05:30:00 12:00:00 20:00:00 21:00:00"
                            ;;
                        "winter")
                            echo "06:30:00 07:00:00 07:30:00 12:00:00 16:30:00 17:00:00"
                            ;;
                        *)
                            echo "05:30:00 06:00:00 06:30:00 12:00:00 18:00:00 18:30:00"
                            ;;
                    esac
                else
                    case $season in
                        "summer")
                            echo "03:00:00 03:30:00 04:00:00 12:00:00 21:00:00 22:00:00"
                            ;;
                        "winter")
                            echo "08:00:00 09:00:00 10:00:00 12:00:00 14:00:00 15:00:00"
                            ;;
                        *)
                            echo "05:00:00 06:00:00 07:00:00 12:00:00 18:00:00 19:00:00"
                            ;;
                    esac
                fi
            }

            # $1 = key in the API response, $2 = fallback time
            get_time() {
                local time_raw=""
                local time=""

                if [ -n "$response" ]; then
                    time_raw=$(echo "$response" | jq -r ".results.$1 // empty" 2>/dev/null)
                fi

                if [ -n "$time_raw" ] && [ "$time_raw" != "null" ]; then
                    time=$(date -d "$time_raw" +%T 2>/dev/null)
                fi

                # API missing or unparseable — fall back to the seasonal default
                if [ -z "$time" ]; then
                    time=$(date -d "$2" +%T)
                fi

                echo "$time"
            }

            is_number() {
                [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]
            }

            loc_response=$(curl -s --max-time 10 http://ip-api.com/json/ || true)
            LATITUDE=$(echo "$loc_response" | jq -r '.lat // empty' 2>/dev/null)
            LONGITUDE=$(echo "$loc_response" | jq -r '.lon // empty' 2>/dev/null)

            # Geolocation failed — keep whatever we resolved last run, else Greenwich
            if ! is_number "$LATITUDE" || ! is_number "$LONGITUDE"; then
                echo "Warning: geolocation lookup failed, reusing previous coordinates" >&2
                LATITUDE=$(systemctl --user show-environment | grep "^LATITUDE=" | cut -d= -f2-)
                LONGITUDE=$(systemctl --user show-environment | grep "^LONGITUDE=" | cut -d= -f2-)
            fi
            is_number "$LATITUDE" || LATITUDE=51.4769
            is_number "$LONGITUDE" || LONGITUDE=0.0

            systemctl --user set-environment LATITUDE="$LATITUDE"
            systemctl --user set-environment LONGITUDE="$LONGITUDE"

            hemisphere=$(awk -v LATITUDE="$LATITUDE" 'BEGIN {print (LATITUDE >= 0 ? "north" : "south")}')
            season=$(get_season $hemisphere)

            default_times=($(get_default_times $LATITUDE $season))

            response=$(curl -s --max-time 10 "https://api.sunrisesunset.io/json?lat=$LATITUDE&lng=$LONGITUDE" || true)
            if [ "$(echo "$response" | jq -r '.status // empty' 2>/dev/null)" != "OK" ]; then
                echo "Warning: sunrisesunset.io unavailable, using seasonal defaults" >&2
                response=""
            fi

            DAWN=$(get_time "dawn" "''${default_times[1]}")
            systemctl --user set-environment DAWN="$DAWN"

            SUNRISE=$(get_time "sunrise" "''${default_times[2]}")
            systemctl --user set-environment SUNRISE="$SUNRISE"

            SOLAR_NOON=$(get_time "solar_noon" "''${default_times[3]}")
            systemctl --user set-environment SOLAR_NOON="$SOLAR_NOON"

            SUNSET=$(get_time "sunset" "''${default_times[4]}")
            systemctl --user set-environment SUNSET="$SUNSET"

            # Calculate FIRST_LIGHT as 45 minutes before DAWN
            FIRST_LIGHT=$(date -d "$DAWN 45 minutes ago" +%T)
            systemctl --user set-environment FIRST_LIGHT="$FIRST_LIGHT"

            # Calculate LAST_LIGHT as 45 minutes after SUNSET
            LAST_LIGHT=$(date -d "$SUNSET 45 minutes" +%T)
            systemctl --user set-environment LAST_LIGHT="$LAST_LIGHT"
          ''}";
        };

        Install = {
          WantedBy = ["default.target"];
        };
      };

      systemd.user.timers."anti-sleep-neglector" = {
        Unit = {
          Description = "Refresh circadian period env variables";
        };

        Timer = {
          OnCalendar = "daily";
          OnBootSec = "1s";
          Persistent = true;
          Unit = "anti-sleep-neglector.service";
        };

        Install = {
          WantedBy = ["timers.target"];
        };
      };
    })

    (mkIf config.services.anti-sleep-neglector-monitor.enable {
      # doesnt work
      # wayland.windowManager.hyprland.systemd.extraCommands = ["systemctl --user enable --now hyprsunset.service"];
      # wayland.windowManager.hyprland.plugins = [pkgs.hyprsunset];
      systemd.user.services."anti-sleep-neglector-monitor" = {
        Unit = {
          Description = "Run anti sleep neglector automatic monitor brightness control";
          PartOf = ["graphical-session.target"];
          Requires = ["anti-sleep-neglector.service"];
          # sunsetr must be up before set_period checks for it
          After = ["graphical-session.target" "anti-sleep-neglector.service" "sunsetr.service"];
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScript "set-monitor-brightness" ''
            #!/usr/bin/env bash
            PATH=$PATH:${lib.makeBinPath [
              pkgs.coreutils
              pkgs.gawk
              pkgs.gnugrep
              pkgs.brightnessctl
              pkgs.systemd
              pkgs.sunsetr
              hyprlandPkg
            ]}

            set -x
            exec &> /tmp/anti-sleep-neglector-monitor.log

            ${circadianVars}
            refresh_circadian_vars

            time_to_minutes() {
                IFS=: read -r h m s <<< "$1"
                echo $(( 10#$h * 60 + 10#$m ))
            }

            current_time=$(date +%H:%M:%S)
            current_minutes=$(time_to_minutes "$current_time")

            first_light_min=$(time_to_minutes "$FIRST_LIGHT")
            dawn_min=$(time_to_minutes "$DAWN")
            sunrise_min=$(time_to_minutes "$SUNRISE")
            solar_noon_min=$(time_to_minutes "$SOLAR_NOON")
            sunset_min=$(time_to_minutes "$SUNSET")
            last_light_min=$(time_to_minutes "$LAST_LIGHT")

            max_brightness=$(brightnessctl max | awk '{print $1}')

            night_brightness=${toString config.services.anti-sleep-neglector-monitor.nightBrightness}
            day_brightness=${toString config.services.anti-sleep-neglector-monitor.dayBrightness}

            # Brightness based on current time
            calculate_brightness() {
                local start_time=$1
                local end_time=$2
                local start_brightness=$3
                local end_brightness=$4

                local time_range=$((end_time - start_time))
                local brightness_range=$((end_brightness - start_brightness))
                local time_elapsed=$((current_minutes - start_time))

                local brightness_percent
                if [ $time_range -eq 0 ]; then
                    brightness_percent=$start_brightness
                else
                    brightness_percent=$(( start_brightness + (brightness_range * time_elapsed / time_range) ))
                fi

                echo $(( max_brightness * brightness_percent / 100 ))
            }

            # Hyprland only. Lua config: `hyprctl keyword` is gone, eval sets options
            set_shader() {
              hyprctl eval "hl.config({ decoration = { screen_shader = \"$1\" } })"
            }

            # anti-sleep-neglector-lifx touches this while its bulbs answer
            lifx_owns_sunsetr() {
              local marker="$XDG_RUNTIME_DIR/anti-sleep-neglector-lifx"
              [ -e "$marker" ] &&
                [ $(( $(date +%s) - $(stat -c %Y "$marker") )) -lt ${toString (6 * config.services.anti-sleep-neglector-lifx.interval)} ]
            }

            # sunsetr preset where its service runs (niri), else the Hyprland shader.
            # Never call `sunsetr preset` without a running instance: it would start
            # sunsetr in the foreground here. Same name twice toggles back to default.
            set_period() {
              if systemctl --user is-active -q sunsetr.service; then
                lifx_owns_sunsetr && return
                [ "$(sunsetr preset active)" = "$1" ] || timeout 10 sunsetr preset "$1"
              else
                set_shader "${shaderDir}/$1.frag"
              fi
            }

            # Fallback if no branch matches (clock skew, malformed period times)
            desired_brightness=$((max_brightness * night_brightness / 100))

            # Determine appropriate brightness based on current time
            if [ $current_minutes -lt $first_light_min ] || [ $current_minutes -ge $last_light_min ]; then
                # Night time
                desired_brightness=$((max_brightness * night_brightness / 100))

                  ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_period night"
              else ""
            }
            elif [ $current_minutes -lt $dawn_min ]; then
                # First light to dawn
                desired_brightness=$(calculate_brightness $first_light_min $dawn_min $night_brightness $((night_brightness + 20)))

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_period first_light"
              else ""
            }
            elif [ $current_minutes -lt $sunrise_min ]; then
                # Dawn to sunrise
                desired_brightness=$(calculate_brightness $dawn_min $sunrise_min $((night_brightness + 20)) $((day_brightness - 20)))

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_period dawn"
              else ""
            }
            elif [ $current_minutes -lt $solar_noon_min ]; then
                # Sunrise to solar noon
                desired_brightness=$(calculate_brightness $sunrise_min $solar_noon_min $((day_brightness - 20)) $day_brightness)

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_period sunrise"
              else ""
            }
            elif [ $current_minutes -lt $sunset_min ]; then
                # Solar noon to sunset
                desired_brightness=$(calculate_brightness $solar_noon_min $sunset_min $day_brightness $((day_brightness - 20)))

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_period solar_noon"
              else ""
            }
            elif [ $current_minutes -lt $last_light_min ]; then
                # Sunset to last light
                desired_brightness=$(calculate_brightness $sunset_min $last_light_min $((day_brightness - 20)) $night_brightness)

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_period sunset"
              else ""
            }
            fi

            brightnessctl set "$(printf "%.0f" "$desired_brightness")"
          ''}";
        };
      };

      systemd.user.timers."anti-sleep-neglector-monitor" = {
        Unit = {
          Description = "Set brightness periodically";
          PartOf = ["graphical-session.target"];
        };

        Timer = {
          OnActiveSec = "1s";
          OnUnitActiveSec = config.services.anti-sleep-neglector-monitor.interval;
          Unit = "anti-sleep-neglector-monitor.service";
        };

        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    })

    (mkIf config.services.anti-sleep-neglector-gamma.enable (let
      cfg = config.services.anti-sleep-neglector-gamma;
      periodNames = builtins.attrNames cfg.periods;

      lifx = config.services.anti-sleep-neglector-lifx;
      toml = pkgs.formats.toml {};

      sunsetrCommon = {
        backend = "wayland";
        transition_mode = "static";
        smoothing = true;
        # Also the fade when the monitor switches presets
        startup_duration = 10;
        shutdown_duration = 2;
        # 1ms default stutters and lags the cursor on AMD
        adaptive_interval = 144;
      };

      # Presets are standalone configs, not overlays on sunsetr.toml
      sunsetrConfig = period:
        toml.generate "sunsetr-${period}.toml" (sunsetrCommon
          // {
            static_temp = builtins.floor cfg.periods.${period};
            static_gamma = cfg.brightness.${period};
          });

      lifxSync =
        pkgs.writers.writePython3Bin "anti-sleep-neglector-lifx" {flakeIgnore = ["E501"];}
        (builtins.readFile ./lifx.py);
    in {
      home.file =
        builtins.listToAttrs (
          builtins.map (periodName: {
            name = ".config/anti-sleep-neglector/shaders/${periodName}.frag";
            value = {
              text = import ./template.frag.nix {
                temp = toString (config.services.anti-sleep-neglector-gamma.periods.${periodName});
                glowStrength = config.services.anti-sleep-neglector-gamma.crt-effect.glowStrength;
                glowRadius = config.services.anti-sleep-neglector-gamma.crt-effect.glowRadius;
                scanlineFrequency = config.services.anti-sleep-neglector-gamma.crt-effect.scanlineFrequency;
                scanlineIntensity = config.services.anti-sleep-neglector-gamma.crt-effect.scanlineIntensity;
                curvatureStrength = config.services.anti-sleep-neglector-gamma.crt-effect.curvatureStrength;
                brightness = config.services.anti-sleep-neglector-gamma.crt-effect.brightness;
                contrast = config.services.anti-sleep-neglector-gamma.crt-effect.contrast;
              };
            };
          })
          periodNames
        )
        // builtins.listToAttrs (
          builtins.map (periodName: {
            name = ".config/sunsetr/presets/${periodName}/sunsetr.toml";
            value.source = sunsetrConfig periodName;
          })
          periodNames
        )
        # Used until the monitor picks a preset
        // {".config/sunsetr/sunsetr.toml".source = sunsetrConfig "solar_noon";};

      # niri has no screen shaders; sunsetr sets temperature and gamma over
      # wlr-gamma-control instead. Hyprland keeps the shader.
      systemd.user.services.sunsetr = {
        Unit = {
          Description = "Per-period colour temperature and dimming for anti-sleep-neglector";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
          ConditionEnvironment = "NIRI_SOCKET";
        };
        Service = {
          ExecStart = "${pkgs.sunsetr}/bin/sunsetr";
          # Apply the current period now, not on the monitor's next tick
          ExecStartPost = mkIf config.services.anti-sleep-neglector-monitor.enable "${pkgs.systemd}/bin/systemctl --user start --no-block anti-sleep-neglector-monitor.service";
          Restart = "on-failure";
          RestartSec = "30s";
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      systemd.user.services.anti-sleep-neglector-lifx = mkIf lifx.enable {
        Unit = {
          Description = "Follow LIFX group ${lifx.group} with sunsetr";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target" "sunsetr.service"];
          ConditionEnvironment = "NIRI_SOCKET";
        };
        Service = {
          ExecStart = "${lifxSync}/bin/anti-sleep-neglector-lifx";
          Environment = [
            "PATH=${lib.makeBinPath [pkgs.systemd pkgs.sunsetr]}"
            ''"LIFX_GROUP=${lifx.group}"''
            "LIFX_INTERVAL=${toString lifx.interval}"
            "LIFX_BRIGHTNESS_FLOOR=${toString lifx.brightnessFloor}"
            "LIFX_PORT=${toString lifx.port}"
            # Short fade so the display keeps up with the bulbs
            "LIFX_SUNSETR_BASE=${toml.generate "sunsetr-lifx-base.toml" (sunsetrCommon // {startup_duration = 2;})}"
          ];
          Restart = "on-failure";
          RestartSec = "10s";
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    }))

    (mkIf config.services.anti-sleep-neglector-lifx.enable {
      assertions = [
        {
          assertion = config.services.anti-sleep-neglector-gamma.enable;
          message = "services.anti-sleep-neglector-lifx drives sunsetr; enable services.anti-sleep-neglector-gamma too.";
        }
      ];
    })

    (mkIf config.services.anti-sleep-neglector-wallpaper.enable {
      systemd.user.services."anti-sleep-neglector-wallpaper" = {
        Unit = {
          Description = "Whether to enable anti-sleep-neglector selecting wallpapers by brightness and circadian period.";
          PartOf = ["graphical-session.target"];
          Requires = ["anti-sleep-neglector.service"];
          After = ["graphical-session.target" "anti-sleep-neglector.service"];
        };

        Service = {
          Type = "simple";
          Restart = "always";
          RestartSec = "30s";
          ExecStart = let
            displayUtils = pkgs.writeShellScript "display-utils" ''
              get_main_monitor_resolution() {
                local resolution
                # Focused output, else the first
                if resolution=$(wm outputs | jq -er '(map(select(.focused)) + .)[0].mode | "\(.width) \(.height)"'); then
                  echo "$resolution"
                # Fallback to X11
                elif command -v xrandr >/dev/null; then
                  xrandr --query | awk '/ connected.*primary/{gsub("[x+]", " "); print $3, $4}' | head -n1
                else
                  echo "Unable to detect display resolution" >&2
                  return 1
                fi
              } 2>> /tmp/anti-sleep-neglector-wallpaper.log

              should_no_resize() {
                local image_w=$1
                local image_h=$2
                local monitor_w monitor_h

                read -r monitor_w monitor_h < <(get_main_monitor_resolution 2>/dev/null)

                # Detection failed or returned junk — assume 1080p
                [[ "$monitor_w" =~ ^[0-9]+$ ]] || monitor_w=1920
                [[ "$monitor_h" =~ ^[0-9]+$ ]] || monitor_h=1080

                threshold_w=$(bc <<< "scale=0; $monitor_w * 0.8 / 1" 2>/dev/null || echo 1536)
                threshold_h=$(bc <<< "scale=0; $monitor_h * 0.8 / 1" 2>/dev/null || echo 864)

                if (( image_w < threshold_w || image_h < threshold_h )); then
                  echo "--no-resize"
                fi
              }
            '';
          in "${pkgs.writeShellScript "set-wallpaper" ''
            #!/usr/bin/env bash
            PATH=$PATH:${lib.makeBinPath [
              pkgs.coreutils
              pkgs.gawk
              pkgs.gnugrep
              pkgs.findutils
              pkgs.jq
              pkgs.bc
              pkgs.procps
              pkgs.systemd
              (pkgs.imagemagick_light.override {
                zlibSupport = true;
                libjpegSupport = true;
                libpngSupport = true;
                libwebpSupport = true;
                lcms2Support = true;
              })
              pkgs.wm
              inputs.swww.packages.${pkgs.system}.swww
              pkgs.mpvpaper
              pkgs.ffmpeg-headless
            ]}

            source ${displayUtils}

            set -x
            exec &> /tmp/anti-sleep-neglector-wallpaper.log

            export RUST_BACKTRACE=1

            WALLPAPERS_DIR="${config.services.anti-sleep-neglector-wallpaper.wallpapersDir}"

            if ! pgrep -x "swww-daemon" > /dev/null; then
              swww-daemon &
            fi

            # swww img fails until the daemon is accepting connections
            for _ in $(seq 1 30); do
              swww query >/dev/null 2>&1 && break
              sleep 1
            done

            ${circadianVars}

            time_to_seconds() {
                IFS=: read -r h m s <<< "$1"
                echo $(( 10#$h * 3600 + 10#$m * 60 + 10#''${s:-0} ))
            }

            seconds_to_time() {
                printf '%02d:%02d:%02d\n' $(( $1 / 3600 )) $(( ($1 % 3600) / 60 )) $(( $1 % 60 ))
            }

            # Seconds since midnight — must match the period values it is compared against
            get_current_time_seconds() {
                time_to_seconds "$(date +%H:%M:%S)"
            }

            declare -A periods
            declare -a sorted_periods

            load_periods() {
                refresh_circadian_vars

                periods[FIRST_LIGHT]=$(time_to_seconds "$FIRST_LIGHT")
                periods[DAWN]=$(time_to_seconds "$DAWN")
                periods[SUNRISE]=$(time_to_seconds "$SUNRISE")
                periods[SOLAR_NOON]=$(time_to_seconds "$SOLAR_NOON")
                periods[SUNSET]=$(time_to_seconds "$SUNSET")
                periods[LAST_LIGHT]=$(time_to_seconds "$LAST_LIGHT")

                sorted_periods=($(for period in "''${!periods[@]}"; do echo "''${periods[$period]}:$period"; done | sort -n | cut -d: -f2))
            }

            get_current_period() {
                local current_time
                current_time=$(get_current_time_seconds)
                for period in "''${sorted_periods[@]}"; do
                    if (( current_time < periods[$period] )); then
                        echo "$period"
                        return
                    fi
                done
                echo "''${sorted_periods[0]}"  # If after last period, return first period of next day
            }

            # Seconds-since-midnight of the period following $1
            get_next_period_seconds() {
                local current_period=$1
                for i in "''${!sorted_periods[@]}"; do
                    if [[ "''${sorted_periods[$i]}" == "$current_period" ]]; then
                        local next_index=$(( (i + 1) % ''${#sorted_periods[@]} ))
                        echo "''${periods[''${sorted_periods[$next_index]}]}"
                        return
                    fi
                done
                echo ""
            }

            is_video() {
              case "''${1,,}" in
                *.mp4 | *.webm | *.mkv | *.mov | *.avi | *.m4v) return 0 ;;
              esac
              return 1
            }

            # Keyed by "path:mtime" so magick only runs on new or modified files.
            # Sets $BRIGHTNESS rather than echoing — command substitution would run
            # this in a subshell and throw the cache away every call.
            declare -A brightness_cache
            get_brightness() {
              local file="$1"
              local key
              key="$file:$(date -r "$file" +%s 2>/dev/null || echo 0)"

              if [[ -n "''${brightness_cache[$key]:-}" ]]; then
                BRIGHTNESS="''${brightness_cache[$key]}"
                return 0
              fi

              if is_video "$file"; then
                  # Frame 1 s in skips fade-ins; short clips fall back to the first frame
                  BRIGHTNESS=$(
                    { ffmpeg -v error -ss 1 -i "$file" -frames:v 1 -f image2pipe -c:v png - 2>/dev/null ||
                      ffmpeg -v error -i "$file" -frames:v 1 -f image2pipe -c:v png - 2>/dev/null; } |
                      magick - -colorspace gray -format "%[fx:mean]" info: 2>/dev/null
                  )
              elif [[ "$file" == *.gif ]]; then
                  BRIGHTNESS=$(magick "$file[0]" -colorspace gray -format "%[fx:mean]" info: 2>/dev/null)
              else
                  BRIGHTNESS=$(magick "$file" -colorspace gray -format "%[fx:mean]" info: 2>/dev/null)
              fi

              [[ -z "$BRIGHTNESS" ]] && return 1
              brightness_cache[$key]="$BRIGHTNESS"
              return 0
            }

            # Newline separated so filenames with spaces survive
            declare -A grouped_wallpapers
            group_wallpapers() {
                local -a wallpapers=() brightnesses=()
                local min_brightness max_brightness brightness_range threshold1 threshold2
                local wallpaper brightness

                grouped_wallpapers=()

                mapfile -t wallpapers < <(find "$WALLPAPERS_DIR" -maxdepth 1 -type f | sort)
                if (( ''${#wallpapers[@]} == 0 )); then
                    echo "No wallpapers in $WALLPAPERS_DIR" >&2
                    return 1
                fi

                for wallpaper in "''${wallpapers[@]}"; do
                    get_brightness "$wallpaper" || continue
                    brightnesses+=("$BRIGHTNESS")
                done

                if (( ''${#brightnesses[@]} == 0 )); then
                    echo "Could not read brightness of any wallpaper" >&2
                    return 1
                fi

                IFS=$'\n' sorted=($(sort -g <<<"''${brightnesses[*]}"))
                unset IFS
                min_brightness=''${sorted[0]}
                max_brightness=''${sorted[-1]}

                brightness_range=$(bc <<< "$max_brightness - $min_brightness")

                # Define thresholds as percentages of the range
                threshold1=$(bc <<< "$min_brightness + ($brightness_range * 0.33)")
                threshold2=$(bc <<< "$min_brightness + ($brightness_range * 0.66)")

                # Group wallpapers by time period
                for wallpaper in "''${wallpapers[@]}"; do
                    get_brightness "$wallpaper" || continue
                    brightness="$BRIGHTNESS"
                    if (( $(echo "$brightness < $threshold1" | bc -l) )); then
                        grouped_wallpapers[FIRST_LIGHT]+="$wallpaper"$'\n'
                        grouped_wallpapers[LAST_LIGHT]+="$wallpaper"$'\n'
                    elif (( $(echo "$brightness < $threshold2" | bc -l) )); then
                        grouped_wallpapers[DAWN]+="$wallpaper"$'\n'
                        grouped_wallpapers[SUNSET]+="$wallpaper"$'\n'
                    else
                        grouped_wallpapers[SUNRISE]+="$wallpaper"$'\n'
                        grouped_wallpapers[SOLAR_NOON]+="$wallpaper"$'\n'
                    fi
                done
            }

            while true; do
                load_periods
                current_period=$(get_current_period)

                if group_wallpapers; then
                  wallpapers_for_period=()
                  while IFS= read -r line; do
                      [[ -n "$line" ]] && wallpapers_for_period+=("$line")
                  done <<< "''${grouped_wallpapers[$current_period]:-}"

                  # Don't pick the one already showing when there's a choice
                  if (( ''${#wallpapers_for_period[@]} > 1 )); then
                    candidates=()
                    for w in "''${wallpapers_for_period[@]}"; do
                      [[ "$w" != "''${current_wallpaper:-}" ]] && candidates+=("$w")
                    done
                    wallpapers_for_period=("''${candidates[@]}")
                  fi

                  selected_wallpaper=""
                  if [[ ''${#wallpapers_for_period[@]} -gt 0 ]]; then
                    selected_wallpaper=''${wallpapers_for_period[$RANDOM % ''${#wallpapers_for_period[@]}]}
                  fi

                  # Only candidate is already up: leave it (restarting would flash videos)
                  if [[ -n "$selected_wallpaper" && "$selected_wallpaper" != "''${current_wallpaper:-}" ]]; then
                    current_wallpaper=$selected_wallpaper

                    # mpvpaper's layer sits above swww's, so it must go for images to show
                    pkill -x mpvpaper || true

                    if is_video "$selected_wallpaper"; then
                      # -o lines become an mpv config file, so no leading dashes; '#' must be
                      # quoted there. Never upscale, shrink big ones to fit, bars in base00.
                      nohup mpvpaper -o "no-audio loop-file=inf hwdec=auto video-unscaled=downscale-big background-color=\"#${removeHash outputs.palette.base00}\"" \
                        ALL "$selected_wallpaper" </dev/null >>/tmp/anti-sleep-neglector-wallpaper.log 2>&1 &
                    else
                      # Get image dimensions
                      read -r img_w img_h < <(magick identify -format "%w %h\n" "$selected_wallpaper" | head -n1)

                      swww_cmd=(
                        swww img "$selected_wallpaper"
                        --transition-type wipe
                        --transition-angle 30
                        --transition-step 20
                        --transition-fps 144
                        --fill-color ${removeHash outputs.palette.base00}
                      )

                      # Small images at native size, large ones shrunk to fit; never cropped to fill
                      if [[ -n "$(should_no_resize "$img_w" "$img_h")" ]]; then
                        swww_cmd+=(--resize no)
                        echo "Native size for image ($img_w x $img_h)"
                      else
                        swww_cmd+=(--resize fit)
                      fi

                      # No -o: swww sets every output, no compositor-specific listing needed
                      "''${swww_cmd[@]}" </dev/null >>/tmp/anti-sleep-neglector-wallpaper.log 2>&1 &
                    fi
                  fi
                fi

                next_time=$(get_next_period_seconds "$current_period")
                current_time=$(get_current_time_seconds)

                if [[ -n "$next_time" ]]; then
                    wait_time=$((next_time - current_time))
                    # Next period already passed today — wait for tomorrow's occurrence
                    if (( wait_time <= 0 )); then
                        wait_time=$((wait_time + 24*60*60))
                    fi
                else
                    wait_time=0
                fi

                if (( wait_time <= 0 || wait_time > 24*60*60 )); then
                    wait_time=1800  # 30 minutes
                fi

                # Cycle within the period too, not only at its boundaries
                cycle_interval=${toString config.services.anti-sleep-neglector-wallpaper.cycleInterval}
                if (( wait_time > cycle_interval )); then
                    wait_time=$cycle_interval
                fi

                sleep $wait_time
            done
          ''}";
        };

        Install = {
          WantedBy = ["graphical-session.target"];
        };
      };
    })
  ];
}
