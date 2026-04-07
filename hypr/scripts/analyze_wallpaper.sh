#!/bin/bash

# analyze_wallpaper.sh - Analyze image brightness for SDDM theme

IMAGE_FILE="$1"

# Check if ImageMagick is installed
if ! command -v identify &> /dev/null; then
    echo "Error: ImageMagick is required but not installed."
    exit 1
fi

# Check if file exists
if [ ! -f "$IMAGE_FILE" ]; then
    echo "Error: File '$IMAGE_FILE' not found"
    exit 1
fi

# Function to analyze image brightness (optimized version)
analyze_image() {
    local image="$1"
    
    # Create temporary resized image for faster processing
    temp_image=$(mktemp).png
    magick  "$image" -resize "100x100" "$temp_image"
    
    # Get mean brightness (0-100%)
    brightness=$(magick "$temp_image" -colorspace Gray -format "%[fx:mean*100]" info:)
    
    # Clean up
    rm -f "$temp_image"
    
    echo "$brightness"
}

# Analyze image brightness
brightness=$(analyze_image "$IMAGE_FILE")

# Determine if image is light or dark (threshold ~50%)
if (( $(echo "$brightness > 50" | bc -l) )); then
    echo "light"
else
    echo "dark"
fi
