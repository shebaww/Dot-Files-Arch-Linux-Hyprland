#!/bin/bash
# ~/.config/hypr/scripts/battery-alert.sh

# Battery thresholds
LOW_BATTERY=20
CRITICAL_BATTERY=10
NOTIFICATION_COOLDOWN=300  # 5 minutes

# File to track last notification time
COOLDOWN_FILE="/tmp/battery_alert_cooldown"

# Function to get battery info (using your existing method)
get_battery_info() {
    for i in {0..3}; do
        if [ -f "/sys/class/power_supply/BAT$i/capacity" ] && [ -f "/sys/class/power_supply/BAT$i/status" ]; then
            battery_capacity=$(cat "/sys/class/power_supply/BAT$i/capacity")
            battery_status=$(cat "/sys/class/power_supply/BAT$i/status")
            echo "$battery_capacity $battery_status"
            return 0
        fi
    done
    echo ""
}

# Function to show notification
show_notification() {
    local capacity=$1
    local status=$2
    
    if [ "$status" = "Discharging" ]; then
        if [ "$capacity" -le "$CRITICAL_BATTERY" ]; then
            notify-send -u critical -i battery-caution "🚨 CRITICAL BATTERY" "Battery at ${capacity}%! Plug in immediately!"
            # Play alert sound (optional)
            paplay /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga 2>/dev/null || true
        elif [ "$capacity" -le "$LOW_BATTERY" ]; then
            notify-send -u normal -i battery-low "🔋 Low Battery" "Battery at ${capacity}%. Consider plugging in."
        fi
    fi
}

# Function to check if cooldown period has passed
check_cooldown() {
    local current_time=$(date +%s)
    local last_time=0
    
    if [ -f "$COOLDOWN_FILE" ]; then
        last_time=$(cat "$COOLDOWN_FILE")
    fi
    
    if [ $((current_time - last_time)) -ge "$NOTIFICATION_COOLDOWN" ]; then
        echo "$current_time" > "$COOLDOWN_FILE"
        return 0  # Cooldown passed
    else
        return 1  # Still in cooldown
    fi
}

# Main loop
while true; do
    battery_info=$(get_battery_info)
    
    if [ -n "$battery_info" ]; then
        read -r battery_capacity battery_status <<< "$battery_info"
        
        # Only show notification if cooldown has passed and battery is discharging
        if [ "$battery_status" = "Discharging" ]; then
            if check_cooldown; then
                show_notification "$battery_capacity" "$battery_status"
            fi
        fi
    fi
    
    sleep 30
done
