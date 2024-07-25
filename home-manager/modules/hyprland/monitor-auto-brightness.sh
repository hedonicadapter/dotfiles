
#!/usr/bin/env bash

max_brightness=$(brightnessctl max | awk '{print $1}')
while true; do
    # Get the current time in seconds
    current_time=$(date +%s)

    # Define the start and end of the day in seconds (7:00 and 22:00 in this case)
    start_of_day=$(TZ='Europe/Stockholm' date -d"07:00" +%s)
    end_of_day=$(TZ='Europe/Stockholm' date -d"22:00" +%s)

    # Calculate the total length of the day and the elapsed time since the start of the day
    total_day_length=$((end_of_day - start_of_day))
    elapsed_time=$((current_time - start_of_day))

    # Calculate the current time's proportion to the total day length
    proportion=$(echo "$elapsed_time / $total_day_length" | bc -l)

    # Define the maximum and minimum brightness levels
    min_brightness=$((max_brightness / 5))

    proportion=$(echo "$elapsed_time / $total_day_length" | bc -l)

    # Ensure proportion is between 0 and 1
    if (( $(echo "$proportion < 0" | bc -l) )); then
      proportion=0
    elif (( $(echo "$proportion > 1" | bc -l) )); then
      proportion=1
    fi

    desired_brightness=$(echo "$min_brightness + ($max_brightness - $min_brightness) * (1 - $proportion)" | bc -l)

    # Set the brightness to the desired level
    brightnessctl set $(printf "%.0f" $desired_brightness)
    sleep 60
done
