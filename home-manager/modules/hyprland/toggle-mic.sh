#!/usr/bin/env bash

# Get the current status of Capture
capture_status=$(amixer get Capture | tail -n 1 | grep -o '\[on\]\|\[off\]')

if [[ $capture_status == '[off]' ]]; then
    # If Capture is off, turn it on
      pactl set-source-mute alsa_input.pci-0000_00_1f.3.analog-stereo 0
else
    # If Capture is on, turn it off
      pactl set-source-mute alsa_input.pci-0000_00_1f.3.analog-stereo 1
fi
