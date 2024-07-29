#!/usr/bin/env bash
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP &

# nm-applet --indicator &

ags

swww-daemon &

while ! pgrep -x "swww-daemon" >/dev/null
do
    sleep 1
done &

/home/hedonicadapter/.config/hypr/circadian-env-variables.sh &
/home/hedonicadapter/.config/hypr/wallpaper-cycler.sh
/home/hedonicadapter/.config/hypr/monitor-auto-brightness.sh
wlsunset -l "$LATITUDE" -L "$LONGITUDE"


wl-clip-persist --clipboard regular --all-mime-type-regex '(?i)^(?!image/x-inkscape-svg).+'
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store 
