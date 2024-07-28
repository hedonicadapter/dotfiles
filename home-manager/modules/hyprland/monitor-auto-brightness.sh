#!/usr/bin/env bash
function time_to_seconds {
    IFS=":" read -r hour minute second <<< "$1"
    echo $((hour*3600 + minute*60 + second))
}

function lerp {
    echo $(( $1 + ($3 - $1) * (($4 - $2) / ($5 - $2)) ))
}

last_fetch=0

while true; do
    current_time=$(date +%s)

    if (( current_time - last_fetch >= 86400 || last_fetch == 0 )); then
        response=$(curl -s "https://api.sunrisesunset.io/json?lat=$LATITUDE&lng=$LONGITUDE")

        first_light=$(date -d "$(echo $response | jq -r '.results.first_light')" +%T)
        dawn=$(date -d "$(echo $response | jq -r '.results.dawn')" +%T)
        sunrise=$(date -d "$(echo $response | jq -r '.results.sunrise')" +%T)
        solar_noon=$(date -d "$(echo $response | jq -r '.results.solar_noon')" +%T)
        sunset=$(date -d "$(echo $response | jq -r '.results.sunset')" +%T)
        last_light=$(date -d "$(echo $response | jq -r '.results.last_light')" +%T)

        max_brightness=$(brightnessctl max | awk '{print $1}')
        min_brightness=$((max_brightness / 60))

        dawn_brightness=$((max_brightness * 20 / 100))
        sunrise_brightness=$((max_brightness * 70 / 100))
        solar_noon_brightness=$((max_brightness * 100 / 100))
        sunset_brightness=$((max_brightness * 30 / 100))

        brightness_levels=($min_brightness $dawn_brightness $sunrise_brightness $solar_noon_brightness $sunset_brightness $min_brightness)

        times=( $(time_to_seconds $first_light) $(time_to_seconds $dawn) $(time_to_seconds $sunrise) $(time_to_seconds $solar_noon) $(time_to_seconds $sunset) $(time_to_seconds $last_light) )
         
        start_of_day=$(date -d "$(date +%Y-%m-%d)" +%s)
        current_time=$((current_time - start_of_day))

        last_fetch=$current_time
    fi

    for ((i=0; i<${#times[@]}-1; i++)); do
        if (( current_time >= times[i] && current_time < ${times[i+1]} )); then
            desired_brightness=$(lerp ${brightness_levels[i]} ${times[i]} ${brightness_levels[i+1]} ${times[i+1]} $current_time)
            
            brightnessctl set $(printf "%.0f" $desired_brightness)
            break
        fi
    done

    sleep 60
done
