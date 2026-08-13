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
          Your wallpaper directory.
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
          After = ["graphical-session.target" "anti-sleep-neglector.service"];
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

            set_shader() {
              hyprctl keyword decoration:screen_shader "$1"
            }

            # Fallback if no branch matches (clock skew, malformed period times)
            desired_brightness=$((max_brightness * night_brightness / 100))

            # Determine appropriate brightness based on current time
            if [ $current_minutes -lt $first_light_min ] || [ $current_minutes -ge $last_light_min ]; then
                # Night time
                desired_brightness=$((max_brightness * night_brightness / 100))

                  ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_shader ${shaderDir}/night.frag"
              else ""
            }
            elif [ $current_minutes -lt $dawn_min ]; then
                # First light to dawn
                desired_brightness=$(calculate_brightness $first_light_min $dawn_min $night_brightness $((night_brightness + 20)))

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_shader ${shaderDir}/first_light.frag"
              else ""
            }
            elif [ $current_minutes -lt $sunrise_min ]; then
                # Dawn to sunrise
                desired_brightness=$(calculate_brightness $dawn_min $sunrise_min $((night_brightness + 20)) $((day_brightness - 20)))

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_shader ${shaderDir}/dawn.frag"
              else ""
            }
            elif [ $current_minutes -lt $solar_noon_min ]; then
                # Sunrise to solar noon
                desired_brightness=$(calculate_brightness $sunrise_min $solar_noon_min $((day_brightness - 20)) $day_brightness)

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_shader ${shaderDir}/sunrise.frag"
              else ""
            }
            elif [ $current_minutes -lt $sunset_min ]; then
                # Solar noon to sunset
                desired_brightness=$(calculate_brightness $solar_noon_min $sunset_min $day_brightness $((day_brightness - 20)))

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_shader ${shaderDir}/solar_noon.frag"
              else ""
            }
            elif [ $current_minutes -lt $last_light_min ]; then
                # Sunset to last light
                desired_brightness=$(calculate_brightness $sunset_min $last_light_min $((day_brightness - 20)) $night_brightness)

                    ${
              if config.services.anti-sleep-neglector-gamma.enable
              then "set_shader ${shaderDir}/sunset.frag"
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

    (mkIf config.services.anti-sleep-neglector-gamma.enable {
      home.file = builtins.listToAttrs (
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
        (builtins.attrNames config.services.anti-sleep-neglector-gamma.periods)
      );
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
                # Try Hyprland first
                if command -v hyprctl >/dev/null; then
                  hyprctl -j monitors | jq -r '.[0] | "\(.width) \(.height)"'
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
              hyprlandPkg
              inputs.swww.packages.${pkgs.system}.swww
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

              if [[ "$file" == *.gif ]]; then
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

                  if [[ ''${#wallpapers_for_period[@]} -gt 0 ]]; then
                    selected_wallpaper=''${wallpapers_for_period[$RANDOM % ''${#wallpapers_for_period[@]}]}

                    # Get image dimensions
                    read -r img_w img_h < <(magick identify -format "%w %h" "$selected_wallpaper")

                    swww_cmd=(
                      swww img "$selected_wallpaper"
                      --transition-type wipe
                      --transition-angle 30
                      --transition-step 20
                      --transition-fps 144
                      --fill-color ${removeHash outputs.palette.base00}
                    )

                    resize_flag=$(should_no_resize "$img_w" "$img_h")
                    if [[ -n "$resize_flag" ]]; then
                      swww_cmd+=("$resize_flag")
                      echo "Using --no-resize for image ($img_w x $img_h)"
                    fi

                    monitor_names=$(hyprctl monitors all -j | jq -r '.[] | .name')
                    for monitor in $monitor_names; do
                      nohup "''${swww_cmd[@]}" -o "$monitor" </dev/null >>/tmp/anti-sleep-neglector-wallpaper.log 2>&1 &
                    done
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
