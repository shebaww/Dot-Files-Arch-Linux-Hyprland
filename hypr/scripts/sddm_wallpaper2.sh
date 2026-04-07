#!/bin/bash
# SDDM Wallpaper setter script - Fixed Version

# variables
terminal=kitty
sddm_simple="/usr/share/sddm/themes/simple_sddm_2"
sddm_theme_conf="$sddm_simple/theme.conf"

# Directory for swaync
iDIR="$HOME/.config/swaync/images"

# Get current wallpaper from swww
current_wall=$(swww query | grep -oP "image: \K.*" | head -1)

# Check if it's a video wallpaper (can't use for SDDM)
if [[ "$current_wall" =~ \.(mp4|mkv|mov|webm)$ ]]; then
    notify-send -t 5000 "SDDM Wallpaper" "Cannot set video wallpapers for SDDM"
    exit 1
fi

if [[ -z "$current_wall" || ! -f "$current_wall" ]]; then
    notify-send -t 5000 "SDDM Wallpaper" "Could not find current wallpaper"
    exit 1
fi

# Launch terminal and apply changes
$terminal -e bash -c "
echo 'Updating SDDM wallpaper and colors...';
echo 'Current wallpaper: $current_wall';

# Copy wallpaper to SDDM theme
sudo cp \"$current_wall\" \"$sddm_simple/Backgrounds/default\"

if [ \$? -eq 0 ]; then
    echo 'SDDM wallpaper updated successfully!';
    notify-send -t 3000 \"SDDM Wallpaper\" \"Background updated successfully!\"
else
    echo 'Failed to update SDDM wallpaper';
    notify-send -t 5000 \"SDDM Wallpaper\" \"Failed to update background\"
fi

echo 'Press Enter to close...';
read
"
