#!/usr/bin/env bash

set -e

CONFIG_DIR="$HOME/.config/waybar"
POSITION_DIR="$CONFIG_DIR/position"
STATE_FILE="$POSITION_DIR/.current_position"

# Get all directories inside position folder (sorted)
mapfile -t POSITIONS < <(find "$POSITION_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | sort)

# Ensure we actually found folders
if [[ ${#POSITIONS[@]} -eq 0 ]]; then
    echo "No position folders found in $POSITION_DIR"
    exit 1
fi

# Determine current index
CURRENT_INDEX=-1
if [[ -f "$STATE_FILE" ]]; then
    CURRENT_POSITION=$(cat "$STATE_FILE")
    for i in "${!POSITIONS[@]}"; do
        if [[ "${POSITIONS[$i]}" == "$CURRENT_POSITION" ]]; then
            CURRENT_INDEX=$i
            break
        fi
    done
fi

# Compute next position
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#POSITIONS[@]} ))
NEXT_POSITION="${POSITIONS[$NEXT_INDEX]}"

echo "Switching Waybar position to: $NEXT_POSITION"

# Copy everything including hidden files
cp -rf "$POSITION_DIR/$NEXT_POSITION/." "$CONFIG_DIR/"

# Save state
echo "$NEXT_POSITION" > "$STATE_FILE"

# Restart Waybar safely
pkill waybar 2>/dev/null || true
sleep 0.2
nohup waybar >/dev/null 2>&1 &

echo "Done."