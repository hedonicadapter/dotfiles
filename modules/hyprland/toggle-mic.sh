#!/usr/bin/env bash
#
# Get the current status of Capture
status=$(amixer get Capture | grep -o '\[on\]\|\[off\]')

if [[ $status == '[off]' ]]; then
    amixer set Capture cap
else
    amixer set Capture nocap
fi
