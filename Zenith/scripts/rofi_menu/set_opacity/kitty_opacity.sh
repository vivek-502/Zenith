#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Bypasses the disk to keep the UI snappy
hyprctl keyword source "$HOME/.config/rofi/animations/Walker_anim.conf"

# 2. Define file paths
CONFIG_FILE="$HOME/.config/kitty/kitty.conf"
UPDATING_LINE="background_opacity"

# 3. Check if the configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    notify-send -a "System" "Error" "Kitty configuration file not found!"
    exit 1
fi

# 4. Extract current values for the UI
line=$(grep "^$UPDATING_LINE" "$CONFIG_FILE")
current_value=$(echo "$line" | awk '{print $2}')

# 5. Launch Rofi for input
new_value=$(echo "$current_value" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'window { width: 350px; }' \
    -theme-str 'listview { lines: 0; }' \
    -theme-str 'entry { placeholder: "Enter opacity (0.0 - 1.0)"; }' \
    -p "Current: $current_value")

# 6. Function to validate opacity value
function is_valid_opacity {
    [[ $1 =~ ^0(\.[0-9]+)?|1(\.0+)?$ ]]
}

# 7. Action Logic
if [[ -n "$new_value" ]]; then
    if is_valid_opacity "$new_value"; then
        # Update only the background_opacity line using sed
        sed -i "/^background_opacity/s/.*/background_opacity $new_value/" "$CONFIG_FILE"

        # Reload Kitty instances using the USR1 signal
        # This updates all open Kitty windows without closing them
        kill -USR1 $(pgrep kitty) 2>/dev/null
        
        notify-send -a "System" "Kitty Opacity Updated" "Set background_opacity to: $new_value"
    else
        notify-send -a "System" "Invalid Input" "Please enter a value between 0.0 and 1.0."
    fi
fi

disown
exit 0