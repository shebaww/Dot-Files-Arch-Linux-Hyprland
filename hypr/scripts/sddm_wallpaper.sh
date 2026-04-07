#!/bin/bash
# SDDM Wallpaper setter script - Clean Sugar Candy Version

# variables
terminal=kitty
sddm_theme="/usr/share/sddm/themes/sugar-candy"
sddm_theme_conf="$sddm_theme/theme.conf"

# Directory for swaync
iDIR="$HOME/.config/swaync/images"

# Get current wallpaper from swww
current_wall=$(swww query | grep -oP "image: \K.*" | head -1)

# Check if it's a video wallpaper
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
echo 'Updating SDDM Sugar Candy wallpaper...';
echo 'Current wallpaper: $current_wall';

# Create background directory if it doesn't exist
sudo mkdir -p \"$sddm_theme/Backgrounds/\"

# Copy wallpaper to Sugar Candy theme
sudo cp \"$current_wall\" \"$sddm_theme/Backgrounds/current-wallpaper.jpg\"

# ONLY update the Background line - don't touch HaveFormBackground!
sudo sed -i 's|Background=\".*\"|Background=\"Backgrounds/current-wallpaper.jpg\"|' \"$sddm_theme_conf\"

if [ \$? -eq 0 ]; then
    echo '';
    echo '✓ SDDM Sugar Candy wallpaper updated successfully!';
    
    # Ask about restart
    echo '';
    echo 'SDDM needs to be restarted to apply changes.';
    read -p 'Restart SDDM now? (y/N): ' restart_choice
    
    if [[ \$restart_choice == [Yy] ]]; then
        echo 'Restarting SDDM...';
        sudo systemctl restart sddm
    else
        echo 'Changes saved. SDDM will use new wallpaper on next login.';
    fi
    
    notify-send -t 3000 \"SDDM Wallpaper\" \"Sugar Candy background updated successfully!\"
else
    echo '';
    echo '✗ Failed to update SDDM wallpaper';
    notify-send -t 5000 \"SDDM Wallpaper\" \"Failed to update background\"
fi

echo '';
echo 'Press Enter to close...';
read
"
