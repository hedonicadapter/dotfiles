#!/usr/bin/env bash

case $(printf "%s\n" "Shut down" "Reboot" "Sign out" | tofi $@) in
	"Shut down")
		systemctl poweroff
		;;
	"Reboot")
		systemctl reboot
		;;
	"Sign out")
		pkill -u hedonicadapter  
		;;
esac
