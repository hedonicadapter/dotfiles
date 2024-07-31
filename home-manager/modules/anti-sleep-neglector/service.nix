{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.anti-sleep-neglector;
in {
  options = {
    services.anti-sleep-neglector = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable anti-sleep-neglector protocols.
        '';
      };
      longitude = mkOption {
        default = 0;
        description = ''
          Your longitudinal position.
        '';
      };
      latitude = mkOption {
        default = 0;
        description = ''
          Your latitudinal position.
        '';
      };
    };

    services.anti-sleep-neglector-monitor = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable anti-sleep-neglector monitor automatic brightness control.
        '';
      };
    };

    services.anti-sleep-neglector-wallpaper = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable anti-sleep-neglector selecting wallpapers by brightness and circadian period.
        '';
      };
      wallpapersDir = mkOption {
        default = "${config.home.homeDirectory}/Pictures/wallpapers";
        description = ''
          Your wallpaper directory.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services."anti-sleep-neglector" = {
      Unit = {
        Description = "Run anti sleep neglector protocol";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "set_circadian_vars" ''
          #!/usr/bin/env bash

          set -x
          exec &> /tmp/anti-sleep-neglector.log

          get_time() {
              local time_raw
              time_raw=$(echo "$response" | jq -r ".results.$1")
              local time
              if [ "$time_raw" != "null" ]; then
                  time=$(date -d "$time_raw" +%T)
              else
                  time=$(date -d "$2" +%T)
              fi
              echo "$time"
          }

          response=$(curl -s "https://api.sunrisesunset.io/json?lat=${cfg.latitude}&lng=${cfg.longitude}")

          FIRST_LIGHT=$(get_time "first_light" "06:00:00")
          systemctl --user set-environment FIRST_LIGHT="$FIRST_LIGHT"

          DAWN=$(get_time "dawn" "07:00:00")
          systemctl --user set-environment DAWN="$DAWN"

          SUNRISE=$(get_time "sunrise" "08:00:00")
          systemctl --user set-environment SUNRISE="$SUNRISE"

          SOLAR_NOON=$(get_time "solar_noon" "12:00:00")
          systemctl --user set-environment SOLAR_NOON="$SOLAR_NOON"

          SUNSET=$(get_time "sunset" "16:00:00")
          systemctl --user set-environment SUNSET="$SUNSET"

          LAST_LIGHT=$(get_time "last_light" "18:00:00")
          systemctl --user set-environment LAST_LIGHT="$LAST_LIGHT"

        ''}";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.timers."anti-sleep-neglector.timer" = {
      Unit = {
        Description = "Refresh circadian period env variables";
      };

      Timer = {
        OnCalendar = "daily";
        OnBootSec = "5s";
        Persistent = true;
        Unit = "anti-sleep-neglector.service";
      };

      Install = {
        WantedBy = ["timers.target"];
      };
    };

    systemd.user.services."anti-sleep-neglector-monitor" = {
      Unit = {
        Description = "Run anti sleep neglector automatic monitor brightness control";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "set-monitor-brightness" ''
          #!/usr/bin/env bash

          function get_circadian_period() {
            local value
            value=$(systemctl --user show-environment | grep "^$1=" | cut -d= -f2-)
            if [ -z "$value" ]; then
              echo "Error: Variable $1 not found" >&2
              return 1
            fi
            echo "$value"
          }

          set -x
          exec &> /tmp/anti-sleep-neglector-brightness.log

          time_to_seconds() {
              IFS=: read -r h m s <<< "$1"
              echo $(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
          }

          # Get max and min brightness
          max_brightness=$(brightnessctl max | awk '{print $1}')
          min_brightness=$((max_brightness / 40))

          export FIRST_LIGHT=$(get_circadian_period FIRST_LIGHT) DAWN=$(get_circadian_period DAWN) SUNRISE=$(get_circadian_period SUNRISE) SOLAR_NOON=$(get_circadian_period SOLAR_NOON) SUNSET=$(get_circadian_period SUNSET) LAST_LIGHT=$(get_circadian_period LAST_LIGHT) || echo "Failed to update sun variables" &
          current_seconds=$(time_to_seconds "$(date +%T)")
          first_light_seconds=$(time_to_seconds "$FIRST_LIGHT")
          dawn_seconds=$(time_to_seconds "$DAWN")
          sunrise_seconds=$(time_to_seconds "$SUNRISE")
          solar_noon_seconds=$(time_to_seconds "$SOLAR_NOON")
          sunset_seconds=$(time_to_seconds "$SUNSET")
          last_light_seconds=$(time_to_seconds "$LAST_LIGHT")

          # Calculate brightness based on time of day
          if [ $current_seconds -lt $first_light_seconds ] || [ $current_seconds -ge $last_light_seconds ]; then
              # Night time
              desired_brightness=$min_brightness
          elif [ $current_seconds -lt $sunrise_seconds ]; then
              # Dawn
              range=$((sunrise_seconds - first_light_seconds))
              progress=$((current_seconds - first_light_seconds))
              desired_brightness=$(( min_brightness + (max_brightness - min_brightness) * progress / range ))
          elif [ $current_seconds -lt $solar_noon_seconds ]; then
              # Morning
              desired_brightness=$max_brightness
          elif [ $current_seconds -lt $sunset_seconds ]; then
              # Afternoon
              desired_brightness=$max_brightness
          else
              # Dusk
              range=$((last_light_seconds - sunset_seconds))
              progress=$((last_light_seconds - current_seconds))
              desired_brightness=$(( min_brightness + (max_brightness - min_brightness) * progress / range ))
          fi

          # Set the brightness
          brightnessctl set "$(printf "%.0f" "$desired_brightness")"
        ''}";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };

    systemd.user.timers."anti-sleep-neglector-monitor.timer" = {
      Unit = {
        Description = "Set brightness periodically";
      };

      Timer = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
        Unit = "anti-sleep-neglector-monitor.service";
      };

      Install = {
        WantedBy = ["timers.target"];
      };
    };

    systemd.user.services."anti-sleep-neglector-wallpaper" = {
      Unit = {
        Description = "Whether to enable anti-sleep-neglector selecting wallpapers by brightness and circadian period.";
      };

      Service = {
        Type = "simple";
        Restart = "always";
        RestartSec = "30s";
        ExecStart = "${pkgs.writeShellScript "set-wallpaper" ''
          #!/usr/bin/env bash
          export PATH="${pkgs.coreutils}/bin:${pkgs.procps}/bin:$PATH"

          function get_circadian_period() {
            local value
            value=$(systemctl --user show-environment | grep "^$1=" | cut -d= -f2-)
            if [ -z "$value" ]; then
              echo "Error: Variable $1 not found" >&2
              return 1
            fi
            echo "$value"
          }


          set -x
          exec &> /tmp/anti-sleep-neglector-wallpaper.log

          if ! pgrep -x "swww-daemon" > /dev/null; then
              swww-daemon &
          fi
          time_to_minutes_since_midnight() {
              IFS=: read -r h m s <<< "''${1%% *}"
              echo $(( 10#$h * 60 + 10#$m ))
          }


          while true; do
            export FIRST_LIGHT=$(get_circadian_period FIRST_LIGHT) DAWN=$(get_circadian_period DAWN) SUNRISE=$(get_circadian_period SUNRISE) SOLAR_NOON=$(get_circadian_period SOLAR_NOON) SUNSET=$(get_circadian_period SUNSET) LAST_LIGHT=$(get_circadian_period LAST_LIGHT) || echo "Failed to update sun variables" &
            current_time=$(date +%H:%M:%S)
            current_minutes=$(time_to_minutes_since_midnight "$current_time")

            # Convert environment variables to minutes
            first_light_minutes=$(time_to_minutes_since_midnight "$FIRST_LIGHT")
            dawn_minutes=$(time_to_minutes_since_midnight "$DAWN")
            sunrise_minutes=$(time_to_minutes_since_midnight "$SUNRISE")
            solar_noon_minutes=$(time_to_minutes_since_midnight "$SOLAR_NOON")
            sunset_minutes=$(time_to_minutes_since_midnight "$SUNSET")
            last_light_minutes=$(time_to_minutes_since_midnight "$LAST_LIGHT")

            # Determine the brightness range based on current time
            if (( current_minutes < first_light_minutes )); then
                min_brightness=0.0
                max_brightness=0.2
            elif (( current_minutes < dawn_minutes )); then
                min_brightness=0.1
                max_brightness=0.3
            elif (( current_minutes < sunrise_minutes )); then
                min_brightness=0.2
                max_brightness=0.4
            elif (( current_minutes < solar_noon_minutes )); then
                min_brightness=0.4
                max_brightness=0.8
            elif (( current_minutes < sunset_minutes )); then
                min_brightness=0.3
                max_brightness=0.7
            elif (( current_minutes < last_light_minutes )); then
                min_brightness=0.2
                max_brightness=0.4
            else
                min_brightness=0.0
                max_brightness=0.2
            fi

            # Find a suitable wallpaper
            suitable_wallpaper=""
            for wallpaper in "${config.services.anti-sleep-neglector-wallpaper.wallpapersDir}"/*; do
                brightness=$(magick "$wallpaper" -colorspace gray -format "%[fx:mean]" info:)
                if (( $(echo "$brightness >= $min_brightness && $brightness <= $max_brightness" | bc -l) )); then
                    suitable_wallpaper="$wallpaper"
                    break
                fi
            done

            # If no suitable wallpaper found, use the closest match
            if [ -z "$suitable_wallpaper" ]; then
                closest_diff=1
                for wallpaper in "${config.services.anti-sleep-neglector-wallpaper.wallpapersDir}"/*; do
                    brightness=$(magick "$wallpaper" -colorspace gray -format "%[fx:mean]" info:)
                    diff=$(echo "scale=4; a=$brightness - ($min_brightness + $max_brightness)/2; sqrt(a*a)" | bc)
                    if (( $(echo "$diff < $closest_diff" | bc -l) )); then
                        closest_diff=$diff
                        suitable_wallpaper="$wallpaper"
                    fi
                done
            fi

            # Set the wallpaper
            if [ -n "$suitable_wallpaper" ]; then
                echo $suitable_wallpaper
                swww img "$suitable_wallpaper" --transition-type wipe --transition-angle 30 --transition-step 20 --transition-fps 144
            else
                echo "No suitable wallpaper found."
            fi

            sleep 45m
          done
        ''}";
      };

      Install = {
        WantedBy = ["default.target"];
      };
    };
  };
}
# wlsunset -l "$LATITUDE" -L "$LONGITUDE"

