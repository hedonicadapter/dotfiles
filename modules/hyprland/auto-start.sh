#!/usr/bin/env bash

# nm-applet --indicator &
hyprctl setcursor Bibata_Ghost 30 &

hyperctl dispatch exec "[workspace 2 silent] easyeffects" &
hyperctl dispatch exec "[workspace 2 silent] beeper --disable-features=WaylandFractionalScaleV1 --hidden false" &
hyperctl dispatch exec "[workspace 2 silent] wrap-obsidian" &

ags &

swww-daemon &

while ! pgrep -x "swww-daemon" >/dev/null
do
    sleep 1
done

/home/hedonicadapter/.config/hypr/wallpaper-cycler.sh &

wlsunset -l 57.7 -L 12 & 

wl-clip-persist --clipboard regular --all-mime-type-regex '(?i)^(?!image/x-inkscape-svg).+' &
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &
