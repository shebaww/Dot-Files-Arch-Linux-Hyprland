#!/bin/bash

while true; do
    # Check if device is available
    if ! fprintd-list "$USER" 2>/dev/null | grep -q "Fingerprints for user"; then
        # Device missing, try to reset
        if lsusb | grep -q "06cb:0124"; then
            # Device is present in USB but not in fprintd
            notify-send -u normal "Fingerprint" "Reader unresponsive, resetting..."
            sudo /usr/local/bin/usb-reset /dev/bus/usb/003/002
            sudo systemctl restart fprintd
        fi
    fi
    sleep 30
done
