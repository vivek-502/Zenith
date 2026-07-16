#!/usr/bin/env bash

set -euo pipefail

# 1. RAM Injection
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

CONFIG_FILE="$HOME/.config/hypr/decorations.lua"

# 2. Validation
if [[ ! -f "$CONFIG_FILE" ]]; then
    notify-send -a "System" "Error" "Decorations config not found!"
    exit 1
fi

# 3. Extract Current Value (Lua-specific parsing)
current_value=$(grep "gaps_out[[:space:]]*=" "$CONFIG_FILE" | grep -oE "[0-9]+")

# 4. Rofi Menu
new_value=$(echo "$current_value" | rofi -dmenu -i \
    -config ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'window { width: 350px; }' \
    -theme-str 'listview { lines: 0; }' \
    -theme-str 'entry { placeholder: "Gaps Out (0-50)"; }' \
    -p "Gaps Out")

# 5. Logic & Application
if [[ -n "$new_value" && "$new_value" =~ ^[0-9]+$ ]]; then
    # Update Lua Config using sed
    sed -i "s/gaps_out[[:space:]]*=[[:space:]]*[0-9]*/gaps_out = $new_value/" "$CONFIG_FILE"
    
    # Live Update Hyprland
    hyprctl keyword general:gaps_out "$new_value"
    
    notify-send -a "System" "Hyprland" "Gaps Out set to $new_value"
else
    [[ -n "$new_value" ]] && notify-send -a "System" "Invalid Input" "Please enter an integer."
fi

disown
exit 0