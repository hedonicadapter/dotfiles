# swww-daemon &
# while ! pgrep -x "swww-daemon" >/dev/null
# do
#     sleep 1
# done &
#
# time_to_minutes_since_midnight() {
#     IFS=: read -r h m s <<< "''${1%% *}"
#     echo $(( 10#$h * 60 + 10#$m ))
# }
#
# while true; do
#     current_time=$(date +%H:%M:%S)
#     current_minutes=$(time_to_minutes_since_midnight "$current_time")
#
#     # Convert environment variables to minutes
#     first_light_minutes=$(time_to_minutes_since_midnight "$FIRST_LIGHT")
#     dawn_minutes=$(time_to_minutes_since_midnight "$DAWN")
#     sunrise_minutes=$(time_to_minutes_since_midnight "$SUNRISE")
#     solar_noon_minutes=$(time_to_minutes_since_midnight "$SOLAR_NOON")
#     sunset_minutes=$(time_to_minutes_since_midnight "$SUNSET")
#     last_light_minutes=$(time_to_minutes_since_midnight "$LAST_LIGHT")
#
#     # Determine the brightness range based on current time
#     if (( current_minutes < first_light_minutes )); then
#         min_brightness=0.0
#         max_brightness=0.2
#     elif (( current_minutes < dawn_minutes )); then
#         min_brightness=0.1
#         max_brightness=0.3
#     elif (( current_minutes < sunrise_minutes )); then
#         min_brightness=0.2
#         max_brightness=0.4
#     elif (( current_minutes < solar_noon_minutes )); then
#         min_brightness=0.4
#         max_brightness=0.8
#     elif (( current_minutes < sunset_minutes )); then
#         min_brightness=0.3
#         max_brightness=0.7
#     elif (( current_minutes < last_light_minutes )); then
#         min_brightness=0.2
#         max_brightness=0.4
#     else
#         min_brightness=0.0
#         max_brightness=0.2
#     fi
#
#     # Find a suitable wallpaper
#     suitable_wallpaper=""
#     for wallpaper in "$WALLPAPERS_DIR"/*; do
#         brightness=$(magick "$wallpaper" -colorspace gray -format "%[fx:mean]" info:)
#         if (( $(echo "$brightness >= $min_brightness && $brightness <= $max_brightness" | bc -l) )); then
#             suitable_wallpaper="$wallpaper"
#             break
#         fi
#     done
#
#     # If no suitable wallpaper found, use the closest match
#     if [ -z "$suitable_wallpaper" ]; then
#         closest_diff=1
#         for wallpaper in "$WALLPAPERS_DIR"/*; do
#             brightness=$(magick "$wallpaper" -colorspace gray -format "%[fx:mean]" info:)
#             diff=$(echo "scale=4; a=$brightness - ($min_brightness + $max_brightness)/2; sqrt(a*a)" | bc)
#             if (( $(echo "$diff < $closest_diff" | bc -l) )); then
#                 closest_diff=$diff
#                 suitable_wallpaper="$wallpaper"
#             fi
#         done
#     fi
#
#     # Set the wallpaper
#     if [ -n "$suitable_wallpaper" ]; then
#         swww img "$suitable_wallpaper" --transition-type wipe --transition-angle 30 --transition-step 20 --transition-fps 144
#     else
#         echo "No suitable wallpaper found."
#     fi
#
#     sleep 45m
# done
          # Function to get average brightness of an image
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
              for wallpaper in "${wallpapersDir}"/*; do
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

              # Get current period
              current_period=$(get_current_period)

              # Select and set wallpaper
              wallpapers_for_period=(''${grouped_wallpapers[$current_period]})
              if [[ ''${#wallpapers_for_period[@]} -gt 0 ]]; then
                  selected_wallpaper=''${wallpapers_for_period[$RANDOM % ''${#wallpapers_for_period[@]}]}
                  swww img "$selected_wallpaper" --transition-type wipe --transition-angle 30 --transition-step 20 --transition-fps 144
              fi

              # Calculate time to next period
              next_period=$(get_next_period "$current_period")
              current_time=$(get_current_time_seconds)
              next_time=''${periods[$next_period]}
              if (( next_time <= current_time )); then
                  next_time=$(( next_time + 24*60*60 ))  # Add 24 hours if next period is tomorrow
              fi
              wait_time=$(( next_time - current_time ))

              # Wait until next period
              sleep $wait_time
          done
