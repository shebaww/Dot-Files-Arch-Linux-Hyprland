#!/bin/bash

if pgrep -x "cairo-dock" > /dev/null; then
    # Cairo is running, switch to Waybar
    (pkill -x "cairo-dock"; sleep 1; nohup waybar > /dev/null 2>&1 &) &
    notify-send 'Linux Version'
else
    # Waybar is running (or neither), switch to Cairo
    (pkill -SIGUSR1 waybar; sleep 0.5; nohup cairo-dock -cf > /dev/null 2>&1 &) &
    notify-send 'Mac Version'
fi
