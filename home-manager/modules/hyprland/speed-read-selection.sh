#!/usr/bin/env bash
old_clipboard=$(wl-paste)
wl-copy & wl-paste | speedread -w 400; echo "Press Enter to close..."; read &

sleep 1

echo "$old_clipboard" | wl-copy
