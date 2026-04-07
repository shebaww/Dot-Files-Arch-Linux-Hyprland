#!/bin/bash
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

STATE_FILE="/tmp/hotspot-state"

# Check current state
if [[ -f "$STATE_FILE" ]] && [[ $(cat "$STATE_FILE") == "active" ]]; then
    # Hotspot was active, turn it off
    nmcli con down "Hotspot-1" 2>/dev/null
    nmcli con delete "Hotspot-1" 2>/dev/null
    rm -f "$STATE_FILE"
    notify-send "Hotspot" "🔴 Hotspot stopped"
else
    # Create hotspot
    nmcli dev disconnect wlan1 2>/dev/null
    sleep 2
    
    if nmcli dev wifi hotspot ifname wlan1 ssid MyHotspot password MyPassword123; then
        nmcli con mod "Hotspot" connection.id "Hotspot-1" 2>/dev/null
        echo "active" > "$STATE_FILE"
        notify-send -t 5000 "Hotspot" "✅ Hotspot started\nSSID: MyHotspot\nPassword: MyPassword123"
    else
        notify-send "Hotspot Error" "❌ Failed to start hotspot"
    fi
fi
