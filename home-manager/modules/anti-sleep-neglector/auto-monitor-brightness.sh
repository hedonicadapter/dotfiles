time_to_seconds() {
    IFS=: read -r h m s <<< "$1"
    echo $(( 10#$h * 3600 + 10#$m * 60 + 10#$s ))
}

# Get max and min brightness
max_brightness=$(brightnessctl max | awk '{print $1}')
min_brightness=$((max_brightness / 40))

while true; do
    refresh_circadian
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

    sleep 60
done
