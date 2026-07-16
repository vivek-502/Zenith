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
# Extracts the number after 'passes =' inside the 'blur =' block
current_value=$(grep -A 5 "blur =" "$CONFIG_FILE" | grep "passes" | grep -oE "[0-9]+")

# 4. Rofi Menu
new_value=$(echo "$current_value" | rofi -dmenu -i \
    -config ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'window { width: 350px; }' \
    -theme-str 'listview { lines: 0; }' \
    -theme-str 'entry { placeholder: "Blur Strength (0 for Off)"; }' \
    -p "Blur")

# 5. Logic & Application
if [[ -n "$new_value" && "$new_value" =~ ^[0-9]+$ ]]; then
    (
        if [[ "$new_value" -eq 0 ]]; then
            # Disable in Lua Config
            sed -i '/blur = {/,/}/s/enabled[[:space:]]*=[[:space:]]*true/enabled = false/' "$CONFIG_FILE"
            
            # Live Update
            hyprctl keyword decoration:blur:enabled false
            notify-send -a "System" "Hyprland" "Blur Disabled"
        else
            new_passes="$new_value"
            new_size=$((new_value - 1))

            # Enable in Lua Config
            sed -i '/blur = {/,/}/s/enabled[[:space:]]*=[[:space:]]*false/enabled = true/' "$CONFIG_FILE"
            
            # Update size and passes in Lua Config
            sed -i "/blur = {/,/}/s/size[[:space:]]*=[[:space:]]*[0-9]*/size = $new_size/" "$CONFIG_FILE"
            sed -i "/blur = {/,/}/s/passes[[:space:]]*=[[:space:]]*[0-9]*/passes = $new_passes/" "$CONFIG_FILE"

            # Live Update
            hyprctl keyword decoration:blur:enabled true
            hyprctl keyword decoration:blur:size "$new_size"
            hyprctl keyword decoration:blur:passes "$new_passes"
            
            notify-send -a "System" "Hyprland" "Blur set to $new_value"
        fi
    ) &
else
    [[ -n "$new_value" ]] && notify-send -a "System" "Invalid Input" "Please enter an integer."
fi

disown
exit 0