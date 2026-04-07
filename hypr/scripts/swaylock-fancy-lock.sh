#!/bin/bash

# Take screenshots for each monitor and create blurred versions
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Get monitor info
OUTPUTS=$(wlr-randr --json | jq -r '.[] | select(.enabled == true) | .name')
IMAGES=()

# Take screenshots
for OUTPUT in $OUTPUTS; do
    IMAGE="$TEMP_DIR/$OUTPUT.png"
    grim -o "$OUTPUT" "$IMAGE"
    # Blur the image
    magick "$IMAGE" -blur 0x5 "$IMAGE"
    IMAGES+=("$IMAGE")
done

# Build swaylock command with images
SWAYLOCK_CMD=(swaylock --color 000000 --show-failed-attempts --indicator-radius 150 --indicator-thickness 15)

# Add each image
for IMAGE in "${IMAGES[@]}"; do
    SWAYLOCK_CMD+=(-i "$IMAGE")
done

# Add other fancy options
SWAYLOCK_CMD+=(--clock --timestr "%H:%M" --datestr "%A, %B %d" --fade-in 0.2)

# Run swaylock
"${SWAYLOCK_CMD[@]}" &
SWAYLOCK_PID=$!

# Monitor for fingerprint
while kill -0 "$SWAYLOCK_PID" 2>/dev/null; do
    if fprintd-verify 2>/dev/null | grep -q "verify-match"; then
        kill -SIGUSR1 "$SWAYLOCK_PID" 2>/dev/null
        loginctl unlock-session 2>/dev/null
        sleep 0.5
        kill "$SWAYLOCK_PID" 2>/dev/null
        break
    fi
    sleep 0.3
done

wait "$SWAYLOCK_PID" 2>/dev/null
