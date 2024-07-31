#!/usr/bin/env bash
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &

# nm-applet --indicator &

ags

wlsunset -l "$LATITUDE" -L "$LONGITUDE"

wl-clip-persist --clipboard regular --all-mime-type-regex '(?i)^(?!image/x-inkscape-svg).+'
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store 
