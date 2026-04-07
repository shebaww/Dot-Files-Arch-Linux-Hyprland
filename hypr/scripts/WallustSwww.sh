#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */ ##
# Wallust Colors for current wallpaper - Optimized with caching

# Configuration
CACHE_DIR="$HOME/.cache/wallust_cache"
CACHE_FILE="$CACHE_DIR/current"
COLORS_CACHE="$CACHE_DIR/colors.json"
mkdir -p "$CACHE_DIR"

# Function to calculate a simple hash of the image (using size + mod time)
get_image_hash() {
    local img="$1"
    if [ -f "$img" ]; then
        # Use file size and modification time as a simple hash
        echo "$(stat -c '%s %Y' "$img")"
    fi
}

# Function to check if colors are cached
check_cached_colors() {
    local img="$1"
    local img_hash=$(get_image_hash "$img")
    
    if [ -f "$CACHE_FILE" ] && [ -f "$COLORS_CACHE" ]; then
        local cached_hash=$(cat "$CACHE_FILE")
        if [ "$cached_hash" = "$img_hash" ]; then
            return 0  # Cache matches
        fi
    fi
    return 1  # Cache doesn't match
}

# Function to update cache
update_cache() {
    local img="$1"
    local img_hash=$(get_image_hash "$img")
    echo "$img_hash" > "$CACHE_FILE"
    
    # Also store the wallpaper path for reference
    echo "$img" > "$CACHE_DIR/last_wallpaper"
}

# Function to get wallpaper path from swww cache (optimized)
get_wallpaper_path() {
    local monitor="$1"
    local cache_file="$HOME/.cache/swww/$monitor"
    
    if [ -f "$cache_file" ]; then
        # More efficient extraction using parameter expansion
        local first_line=$(head -n 1 "$cache_file" | tr -d '\0')
        
        # Remove Lanczos3 prefix if present
        if [[ "$first_line" == Lanczos3* ]]; then
            echo "${first_line#Lanczos3}"
        else
            echo "$first_line"
        fi
    fi
}

# Get current focused monitor
current_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name' | head -1)

if [ -z "$current_monitor" ]; then
    current_monitor=$(hyprctl monitors -j | jq -r '.[0].name')
fi

echo "Current monitor: $current_monitor"

# Get wallpaper path
wallpaper_path=$(get_wallpaper_path "$current_monitor")

# Fallback to swww query if cache doesn't work
if [ -z "$wallpaper_path" ] || [ ! -f "$wallpaper_path" ]; then
    echo "Cache file not found/invalid, trying swww query..."
    wallpaper_path=$(swww query 2>/dev/null | grep -oP "image: \K[^ ]+" | head -1)
fi

# Validate wallpaper
if [ ! -f "$wallpaper_path" ]; then
    echo "ERROR: Could not find wallpaper file"
    notify-send -u critical "Wallust Error" "Could not find wallpaper file"
    exit 1
fi

echo "Wallpaper path: $wallpaper_path"

# Create symlinks/copies (these are fast operations, do them regardless)
ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"
cp -f "$wallpaper_path" "$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"

# Check if we need to run wallust
if check_cached_colors "$wallpaper_path"; then
    echo "Using cached colors for this wallpaper"
    
    # Still need to update applications with existing colors
    # This is much faster than running wallust
    
    # Signal applications to reload their configs
    if pgrep -x "waybar" > /dev/null; then
        pkill -SIGUSR1 waybar 2>/dev/null && echo "Waybar refreshed"
    fi
    
    if pgrep -x "rofi" > /dev/null; then
        pkill -USR1 rofi 2>/dev/null && echo "Rofi refreshed"
    fi
         pkill -USR1 kitty && echo "Kitty refreshed"
    # Show which image is being used
    notify-send -u low "Wallpaper Colors" "Using cached colors for: $(basename "$wallpaper_path")"
    
else
    echo "New wallpaper detected, generating colors with wallust..."
    
    # Run wallust with background flag to prevent blocking
    # -s flag for skip tty changes
    wallust run "$wallpaper_path" -s &
    wallust_pid=$!
    
    # Wait for wallust to complete (with timeout)
    timeout=10
    while kill -0 $wallust_pid 2>/dev/null && [ $timeout -gt 0 ]; do
        sleep 0.5
        ((timeout--))
    done
    
    if [ $timeout -eq 0 ]; then
        echo "Wallust took too long, but continuing..."
        kill $wallust_pid 2>/dev/null
    fi
    
    # Update cache
    update_cache "$wallpaper_path"
    
    # Copy generated colors to cache
    if [ -f "$HOME/.cache/wallust/wallust.json" ]; then
        cp "$HOME/.cache/wallust/wallust.json" "$COLORS_CACHE"
    fi
    
    # Refresh applications
    for app in waybar rofi kitty; do
        if pgrep -x "$app" > /dev/null; then
            pkill -SIGUSR1 "$app" 2>/dev/null && echo "$app refreshed"
            sleep 0.2
        fi
    done
    
    # Notify with image name
    notify-send -u low "Colors Generated" "Wallust applied to: $(basename "$wallpaper_path")"
    
    # Optional: Also copy to a history file
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $(basename "$wallpaper_path")" >> "$CACHE_DIR/history.log"
fi

exit 0
