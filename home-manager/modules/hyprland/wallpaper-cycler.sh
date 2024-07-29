#!/usr/bin/env bash

time_to_minutes_since_midnight() {
    IFS=: read -r h m s <<< "${1%% *}"
    echo $(( 10#$h * 60 + 10#$m ))
}

while true; do
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
    for wallpaper in "$WALLPAPERS_DIR"/*; do
        brightness=$(magick "$wallpaper" -colorspace gray -format "%[fx:mean]" info:)
        if (( $(echo "$brightness >= $min_brightness && $brightness <= $max_brightness" | bc -l) )); then
            suitable_wallpaper="$wallpaper"
            break
        fi
    done

    # If no suitable wallpaper found, use the closest match
    if [ -z "$suitable_wallpaper" ]; then
        closest_diff=1
        for wallpaper in "$WALLPAPERS_DIR"/*; do
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
        swww img "$suitable_wallpaper" --transition-type wipe --transition-angle 30 --transition-step 20 --transition-fps 144
    else
        echo "No suitable wallpaper found."
    fi

    sleep 45m
done
