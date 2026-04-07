#!/bin/bash

# Check if qs is running
if pgrep -x "qs" > /dev/null; then
    # qs is running, just toggle overview
    qs ipc -c "$QS_CONFIG" call overview toggle
else
    # qs is not running, start it and then toggle overview
    qs &
    
    # Give qs a moment to start up
    sleep 0.5
    
    # Toggle overview
    qs ipc -c /home/nahom/.config/quickshell call overview toggle
    fi
