#!/usr/bin/env bash

# Script to update configurations with Git and Nix flakes.
# neovim is dependent on colors so update colors first

update_config() {
    local dir="$1"
    cd "./$dir" || { echo "Failed to change directory to $dir"; exit 1; }
    git add . || { echo "Failed to stage changes in $dir"; exit 1; }
    nix flake update || { echo "Failed to update flakes in $dir"; exit 1; }
    cd - || exit
}

action="$1"

case "$action" in
    "colors"|"neovim"|"main")
        update_config "$action"
        ;;
    "all")
        for config in colors neovim main; do
            ./update.sh "$config" &
        done
        wait
        ;;
    *)
        echo "Unknown action: $action"
        echo "Supported actions: colors, neovim, main, all"
        exit 1
        ;;
esac

exit 0
