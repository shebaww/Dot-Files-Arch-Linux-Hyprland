#!/bin/bash

# Start swaylock with PAM for password
swaylock \
    --color 000000 \
    --show-failed-attempts \
    --indicator-radius 50 \
    --indicator-thickness 6 \
    --line-color 00000000 \
    --inside-color 00000088 \
    --separator-color 00000000 \
    --ring-color FFFFFF \
    --ring-ver-color 00FF00 \
    --ring-wrong-color FF0000 &

SWAYLOCK_PID=$!

# Give swaylock a moment to start
sleep 0.5

# Poll for fingerprint, but stop polling when PAM is active
# We can detect PAM activity by checking if the fingerprint device is in use
while kill -0 "$SWAYLOCK_PID" 2>/dev/null; do
    # Try to verify fingerprint - this will fail if device is busy (PAM using it)
    OUTPUT=$(fprintd-verify 2>&1)
    
    if echo "$OUTPUT" | grep -q "verify-match"; then
        # Fingerprint matched! Unlock
        kill -SIGUSR1 "$SWAYLOCK_PID" 2>/dev/null
        loginctl unlock-session 2>/dev/null
        sleep 0.5
        kill "$SWAYLOCK_PID" 2>/dev/null
        break
    elif echo "$OUTPUT" | grep -q "device is already open"; then
        # PAM is using the device, wait a bit and retry
        sleep 0.5
        continue
    fi
    sleep 0.3
done

wait "$SWAYLOCK_PID" 2>/dev/null
