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

current_time=$(date +%s)

while true; do
    if (( current_time - last_fetch >= 86400 || last_fetch == 0 )); then
        response=$(curl -s "https://api.sunrisesunset.io/json?lat=$LATITUDE&lng=$LONGITUDE")

        FIRST_LIGHT=$(get_time "first_light" "06:00:00 AM")
        export FIRST_LIGHT

        DAWN=$(get_time "dawn" "07:00:00 AM")
        export DAWN

        SUNRISE=$(get_time "sunrise" "08:00:00 AM")
        export SUNRISE

        SOLAR_NOON=$(get_time "solar_noon" "12:00:00 PM")
        export SOLAR_NOON
        echo "$SOLAR_NOON"

        SUNSET=$(get_time "sunset" "16:00:00 PM")
        export SUNSET
        echo "$SUNSET"

        LAST_LIGHT=$(get_time "last_light" "18:00:00 PM")
        export LAST_LIGHT
        echo "$LAST_LIGHT"

        start_of_day=$(date -d "$(date +%Y-%m-%d)" +%s)
        current_time=$((current_time - start_of_day))

        last_fetch=$current_time
        export CURRENT_TIME="$current_time"
    fi

    sleep 60
done
