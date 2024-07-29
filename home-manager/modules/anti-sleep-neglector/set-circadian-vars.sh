#!/usr/bin/env bash

get_time() {
    local time_raw
    time_raw=$(echo "$response" | jq -r ".results.$1")
    local time
    if [ "$time_raw" != "null" ]; then
        time=$(date -d "$time_raw" +%T)
    else
        time="$2"
    fi
    echo "$time"
}


while true; do
    current_time=$(date +%s)
    if (( current_time - last_fetch >= 86400 || last_fetch == 0 )); then
        response=$(curl -s "https://api.sunrisesunset.io/json?lat=$LATITUDE&lng=$LONGITUDE")

        FIRST_LIGHT=$(get_time "first_light" "06:00:00 AM")
        systemctl --user set-environment FIRST_LIGHT="$FIRST_LIGHT"

        DAWN=$(get_time "dawn" "07:00:00 AM")
        systemctl --user set-environment DAWN="$DAWN"

        SUNRISE=$(get_time "sunrise" "08:00:00 AM")
        systemctl --user set-environment SUNRISE="$SUNRISE"

        SOLAR_NOON=$(get_time "solar_noon" "12:00:00 PM")
        systemctl --user set-environment SOLAR_NOON="$SOLAR_NOON"

        SUNSET=$(get_time "sunset" "16:00:00 PM")
        systemctl --user set-environment SUNSET="$SUNSET"

        echo "Script started at $(date)" >> /tmp/anti-sleep-neglector.log
        echo "SUNSET: $SUNSET" >> /tmp/anti-sleep-neglector.log

        LAST_LIGHT=$(get_time "last_light" "18:00:00 PM")
        systemctl --user set-environment LAST_LIGHT="$LAST_LIGHT"

        start_of_day=$(date -d "$(date +%Y-%m-%d)" +%s)
        current_time=$((current_time - start_of_day))

        last_fetch=$current_time
        systemctl --user set-environment SUNSET="$current_time"
    fi

    sleep 60
done
