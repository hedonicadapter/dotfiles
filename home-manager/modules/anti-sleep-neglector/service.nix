# lotta claude.ai juice on here cause idk how to shell script
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.anti-sleep-neglector;
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

    FIRST_LIGHT=$(get_circadian_period FIRST_LIGHT)
    DAWN=$(get_circadian_period DAWN)
    SUNRISE=$(get_circadian_period SUNRISE)
    SOLAR_NOON=$(get_circadian_period SOLAR_NOON)
    SUNSET=$(get_circadian_period SUNSET)
    LAST_LIGHT=$(get_circadian_period LAST_LIGHT)
  '';
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
        Path = with pkgs; [
          "${coreutils}/bin"
          "${jq}/bin"
          "${procps}/bin"
        ];
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

          loc_response=$(curl -s ipinfo.io/loc)
          lat=$(echo "$loc_response" | cut -d ',' -f1)
          long=$(echo "$loc_response" | cut -d ',' -f2)

          response=$(curl -s "https://api.sunrisesunset.io/json?lat=$lat&lng=$long")

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
        Path = with pkgs; [
          "${coreutils}/bin"
          "${brightnessctl}/bin"
        ];
        ExecStart = "${pkgs.writeShellScript "set-monitor-brightness" ''
          #!/usr/bin/env bash

          set -x
          exec &> /tmp/anti-sleep-neglector-monitor.log

          ${circadianVars}

          # Function to convert time to minutes since midnight
          time_to_minutes() {
              IFS=: read -r h m s <<< "$1"
              echo $(( 10#$h * 60 + 10#$m ))
          }

          # Get current time in minutes
          current_time=$(date +%H:%M:%S)
          current_minutes=$(time_to_minutes "$current_time")

          # Convert environment variables to minutes
          first_light_min=$(time_to_minutes "$FIRST_LIGHT")
          dawn_min=$(time_to_minutes "$DAWN")
          sunrise_min=$(time_to_minutes "$SUNRISE")
          solar_noon_min=$(time_to_minutes "$SOLAR_NOON")
          sunset_min=$(time_to_minutes "$SUNSET")
          last_light_min=$(time_to_minutes "$LAST_LIGHT")

          # Get max brightness
          max_brightness=$(brightnessctl max | awk '{print $1}')

          # Define brightness levels (percentages)
          night_brightness=10
          day_brightness=100

          # Function to calculate brightness based on current time
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

          # Determine the appropriate brightness based on current time
          if [ $current_minutes -lt $first_light_min ] || [ $current_minutes -ge $last_light_min ]; then
              # Night time
              desired_brightness=$((max_brightness * night_brightness / 100))
          elif [ $current_minutes -lt $dawn_min ]; then
              # First light to dawn
              desired_brightness=$(calculate_brightness $first_light_min $dawn_min $night_brightness $((night_brightness + 20)))
          elif [ $current_minutes -lt $sunrise_min ]; then
              # Dawn to sunrise
              desired_brightness=$(calculate_brightness $dawn_min $sunrise_min $((night_brightness + 20)) $((day_brightness - 20)))
          elif [ $current_minutes -lt $solar_noon_min ]; then
              # Sunrise to solar noon
              desired_brightness=$(calculate_brightness $sunrise_min $solar_noon_min $((day_brightness - 20)) $day_brightness)
          elif [ $current_minutes -lt $sunset_min ]; then
              # Solar noon to sunset
              desired_brightness=$(calculate_brightness $solar_noon_min $sunset_min $day_brightness $((day_brightness - 20)))
          elif [ $current_minutes -lt $last_light_min ]; then
              # Sunset to last light
              desired_brightness=$(calculate_brightness $sunset_min $last_light_min $((day_brightness - 20)) $night_brightness)
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
        Path = with pkgs; [
          "${coreutils}/bin"
          "${bc}/bin"
          "${procps}/bin"
          "${imagemagick}/bin"
          "${swww}/bin"
        ];
        Restart = "always";
        RestartSec = "30s";
        ExecStart = "${pkgs.writeShellScript "set-wallpaper" ''
          #!/usr/bin/env bash
          set -x
          exec &> /tmp/anti-sleep-neglector-wallpaper.log

          if ! pgrep -x "swww-daemon" > /dev/null; then
            swww-daemon &
          fi

          ${circadianVars}

          get_brightness() {
              magick "$1" -colorspace gray -format "%[fx:mean]" info:
          }

          # Function to get current time in seconds since midnight
          get_current_time_seconds() {
              date +%s
          }

          # Function to convert time string to seconds since midnight
          time_to_seconds() {
              IFS=: read -r h m s <<< "$1"
              echo $(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
          }

          # Initialize daylight periods
          declare -A periods
          periods[FIRST_LIGHT]=$(time_to_seconds "$FIRST_LIGHT")
          periods[DAWN]=$(time_to_seconds "$DAWN")
          periods[SUNRISE]=$(time_to_seconds "$SUNRISE")
          periods[SOLAR_NOON]=$(time_to_seconds "$SOLAR_NOON")
          periods[SUNSET]=$(time_to_seconds "$SUNSET")
          periods[LAST_LIGHT]=$(time_to_seconds "$LAST_LIGHT")

          # Sort periods
          sorted_periods=($(for period in "''${!periods[@]}"; do echo "''${periods[$period]}:$period"; done | sort -n | cut -d: -f2))

          get_current_period() {
              current_time=$(get_current_time_seconds)
              for period in "''${sorted_periods[@]}"; do
                  if (( current_time < periods[$period] )); then
                      echo "$period"
                      return
                  fi
              done
              echo "''${sorted_periods[0]}"  # If after last period, return first period of next day
          }

          get_next_period() {
              current_period=$1
              for i in "''${!sorted_periods[@]}"; do
                  if [[ "''${sorted_periods[$i]}" == "$current_period" ]]; then
                      next_index=$(( (i + 1) % ''${#sorted_periods[@]} ))
                      echo "''${sorted_periods[$next_index]}"
                      return
                  fi
              done
          }

          # Group wallpapers by brightness
          group_wallpapers() {
              declare -A grouped_wallpapers
              for wallpaper in "${config.services.anti-sleep-neglector-wallpaper.wallpapersDir}"/*; do
                  brightness=$(get_brightness "$wallpaper")
                  if (( $(echo "$brightness < 0.3" | bc -l) )); then
                      grouped_wallpapers[FIRST_LIGHT]+="$wallpaper "
                      grouped_wallpapers[LAST_LIGHT]+="$wallpaper "
                  elif (( $(echo "$brightness < 0.5" | bc -l) )); then
                      grouped_wallpapers[DAWN]+="$wallpaper "
                      grouped_wallpapers[SUNSET]+="$wallpaper "
                  else
                      grouped_wallpapers[SUNRISE]+="$wallpaper "
                      grouped_wallpapers[SOLAR_NOON]+="$wallpaper "
                  fi
              done
              echo "$(declare -p grouped_wallpapers)"
          }

          while true; do
              eval "$(group_wallpapers)"
              current_period=$(get_current_period)

              # Select and set wallpaper
              wallpapers_for_period=("''${grouped_wallpapers[$current_period]}")
              if [[ ''${#wallpapers_for_period[@]} -gt 0 ]]; then
                  selected_wallpaper=''${wallpapers_for_period[$RANDOM % ''${#wallpapers_for_period[@]}]}
                  swww img "$selected_wallpaper" --transition-type wipe --transition-angle 30 --transition-step 20 --transition-fps 144
              fi

              # Calculate time to next period
              next_period=$(get_next_period "$current_period")
              next_period_in_seconds=$(date -d "$next_period")
              current_time=$(get_current_time_seconds)
              # Get the start of the current day in Unix timestamp
              start_of_day=$(date -d "today 00:00:00" +%s)

              # Calculate next_time as Unix timestamp
              next_time=$((start_of_day + next_period_in_seconds))

              # If next_time is in the past, add 24 hours
              if (( next_time <= current_time )); then
                  next_time=$((next_time + 24*60*60))
              fi

              wait_time=$((next_time - current_time))

              # Safeguard against negative wait times
              if (( wait_time < 0 )); then
                  echo "Error: Negative wait time calculated. Using default of 60 seconds."
                  wait_time= 30 * 60
              fi

              echo "Debug: start_of_day = $start_of_day"
              echo "Debug: current_time = $current_time"
              echo "Debug: next_time = $next_time"
              echo "Debug: wait_time = $wait_time"

              sleep $wait_time
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

