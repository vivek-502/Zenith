#!/usr/bin/env bash
# ~/.config/Zenith/scripts/workspace/restore-workspace.sh

SCRIPT_DIR="$HOME/.config/Zenith/scripts/workspace"
CACHE_DIR="$HOME/.config/Zenith/.cache/workspace"
MAP_SCRIPT="$SCRIPT_DIR/app-map.sh"

hyprctl eval "dofile('$HOME/.config/rofi/animations/Theme_selector_anim.lua')"

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# 1. Prompt layout profile choices via Rofi if no direct argument is given
if [ -z "$1" ]; then
    OPTIONS=""
    while IFS= read -r -d '' dir; do
        [ -d "$dir" ] || continue
        NAME=$(basename "$dir")
        PREVIEW="$dir/preview.png"
        if [ -f "$PREVIEW" ]; then
            OPTIONS+="${NAME}\0icon\x1f${PREVIEW}\n"
        else
            OPTIONS+="${NAME}\n"
        fi
    done < <(find "$CACHE_DIR" -maxdepth 1 -mindepth 1 -type d -print0)

    # FIX: Check if any layout profiles were actually found
    if [ -z "$OPTIONS" ]; then
        notify-send "Workspace Restorer" "No saved layouts found in cache."
        exit 0
    fi

    CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -theme "~/.config/rofi/theme-switcher.rasi" -show-icons -p "Restore Workspace:" )
    [ -z "$CHOICE" ] && exit 0
else
    CHOICE="$1"
fi

JSON_FILE="$CACHE_DIR/$CHOICE/workspace.json"
if [ ! -f "$JSON_FILE" ]; then
    notify-send "Error" "Layout '$CHOICE' target files missing."
    exit 1
fi

# Function to get current window addresses running under a specific class
get_addresses() {
    hyprctl clients -j | jq -r --arg class "$1" '.[] | select(.class == $class) | .address'
}

# 2. Iterate through window instructions
LEN=$(jq '. | length' "$JSON_FILE")

for ((i=0; i<LEN; i++)); do
    WIN=$(jq -c ".[$i]" "$JSON_FILE")
    CLASS=$(echo "$WIN" | jq -r '.class')
    FLOATING=$(echo "$WIN" | jq -r '.floating')
    FULLSCREEN=$(echo "$WIN" | jq -r '.fullscreen')
    
    X=$(echo "$WIN" | jq -r '.at[0]')
    Y=$(echo "$WIN" | jq -r '.at[1]')
    W=$(echo "$WIN" | jq -r '.size[0]')
    H=$(echo "$WIN" | jq -r '.size[1]')

    # Query command mapping rules
    CMD=$("$MAP_SCRIPT" "$CLASS")
    if [ $? -ne 0 ] || [ -z "$CMD" ]; then
        notify-send -u critical "Missing App Mapping" "Class '$CLASS' has no launcher rule.\nEdit: ~/.config/Zenith/scripts/workspace/app-map.sh"
        continue
    fi

    # Snapshot window signature registry before executing app launch
    OLD_ADDRS=$(get_addresses "$CLASS")

    # Start app thread in back-process
    eval "$CMD" &

    # Poll until window registration surfaces
    NEW_ADDR=""
    for attempt in {1..60}; do
        sleep 0.1
        CURRENT_ADDRS=$(get_addresses "$CLASS")
        NEW_ADDR=$(comm -13 <(echo "$OLD_ADDRS" | sort) <(echo "$CURRENT_ADDRS" | sort) | head -n 1)
        [ -n "$NEW_ADDR" ] && break
    done

    if [ -z "$NEW_ADDR" ]; then
        # Proceed with subsequent items if initial app execution fails
        continue 
    fi

    # 3. Structural Geometry Transformations
    IS_FLOATING=$(hyprctl clients -j | jq -r --arg addr "$NEW_ADDR" '.[] | select(.address == $addr) | .floating')
    
    # Sync Floating States
    if [ "$FLOATING" = "true" ] && [ "$IS_FLOATING" = "false" ]; then
        hyprctl dispatch togglefloating "address:$NEW_ADDR"
    elif [ "$FLOATING" = "false" ] && [ "$IS_FLOATING" = "true" ]; then
        hyprctl dispatch togglefloating "address:$NEW_ADDR"
    fi

    # Apply Coordinates and Bounds (Applies strictly to floating states)
    if [ "$FLOATING" = "true" ]; then
        hyprctl dispatch movewindowpixel "exact $X $Y,address:$NEW_ADDR"
        hyprctl dispatch resizewindowpixel "exact $W $H,address:$NEW_ADDR"
    fi

    # Process Fullscreen Modes
    if [ "$FULLSCREEN" = "true" ]; then
        hyprctl dispatch focuswindow "address:$NEW_ADDR"
        hyprctl dispatch fullscreen 1
    fi
done

notify-send "Workspace Restored" "Layout '$CHOICE' loaded successfully."
