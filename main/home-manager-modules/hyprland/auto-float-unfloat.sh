#!/usr/bin/env bash

# automatically unfloat windows in a workspace when a new window is added to it
unfloat() {
    active_workspace=$(hyprctl activeworkspace | grep 'workspace ID' | awk '{print $3; exit}')
    
    # Check the number of windows in the active workspace
    window_count=$(hyprctl activeworkspace | awk '/windows:/ {print $2; exit}')
    
    # Guard statement: only proceed if there's more than one window
    if [ "$window_count" -le 1 ]; then
        echo "Only one or no windows in workspace $active_workspace. No action needed."
        return
    fi

    # Get the list of clients and filter for floating windows in the active workspace
    floating_windows=$(hyprctl clients | awk -v ws="$active_workspace" '
        /^Window/ {window=$2}
        /floating:/ {floating=$2}
        /workspace:/ {workspace=$2}
        /pid:/ {
            pid=$2
            if (floating != "0" && workspace == ws) {
                print pid
            }
        }
    ')

    # Check if there are any floating windows
    if [ -n "$floating_windows" ]; then
        echo "Setting tiled mode for floating windows in workspace $active_workspace:"
        
        while read -r pid; do
            echo "Setting tiled mode for PID: $pid"
            hyprctl dispatch settiled pid:"$pid"
        done <<< "$floating_windows"
        
        echo "All floating windows in workspace $active_workspace have been set to tiled mode."
    else
        echo "No floating windows found in workspace $active_workspace"
    fi
}

float() {
    active_workspace=$(hyprctl activeworkspace | grep 'workspace ID' | awk '{print $3; exit}')
    window_count=$(hyprctl activeworkspace | awk '/windows:/ {print $2; exit}')

    if [ "$window_count" -le 1 ]; then
        pid=$(hyprctl clients -j | jq -r --arg ws "$active_workspace" '.[] | select(.workspace.id == ($ws | tonumber)) | .pid')
        hyprctl dispatch setfloating pid:"$pid"
        hyprctl dispatch centerwindow pid:"$pid"
        hyprctl dispatch resizeactive exact 90% 80% pid:"$pid"
        return
    fi
}

handle() {
  case $1 in
    openwindow*) unfloat ;;
    movewindow*) unfloat ;;
    closewindow*) float ;;
  esac
}

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock | while read -r line; do handle "$line"; done
