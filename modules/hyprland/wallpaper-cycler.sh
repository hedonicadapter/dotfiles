#!/usr/bin/env bash

# Set the path to the wallpapers directory
wallpapersDir="/home/hedonicadapter/Pictures/wallpapers"

# Get a list of all image files in the wallpapers directory
wallpapers=("$wallpapersDir"/*)

# Start an infinite loop
while true; do
    # Check if the wallpapers array is empty
    if [ ${#wallpapers[@]} -eq 0 ]; then
        # If the array is empty, refill it with the image files
        wallpapers=("$wallpapersDir"/*)
    fi

    # Select a random wallpaper from the array
    wallpaperIndex=$(( RANDOM % ${#wallpapers[@]} ))
    selectedWallpaper="${wallpapers[$wallpaperIndex]}"

    # Update the wallpaper using the swww img command
    swww img "$selectedWallpaper" --transition-type wipe --transition-angle 30 --transition-step 20 --transition-fps 144

    # Remove the selected wallpaper from the array
    unset "wallpapers[$wallpaperIndex]"

    # Reindex the array
    wallpapers=("${wallpapers[@]}")

    if [ $? -ne 0 ]; then
        echo "Error: Failed to set wallpaper to $selectedWallpaper"
    else
        sleep 1h
    fi
done
