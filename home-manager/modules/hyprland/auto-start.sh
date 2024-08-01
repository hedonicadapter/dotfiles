#!/usr/bin/env bash
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &

# nm-applet --indicator &

ags

loc_response=$(curl -s ipinfo.io/loc)
lat=$(echo "$loc_response" | cut -d ',' -f1)
long=$(echo "$loc_response" | cut -d ',' -f2)
wlsunset -l "$lat" -L "$long"

wl-clip-persist --clipboard regular --all-mime-type-regex '(?i)^(?!image/x-inkscape-svg).+'
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store 
