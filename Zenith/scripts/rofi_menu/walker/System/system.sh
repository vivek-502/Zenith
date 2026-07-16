#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# This ensures a smooth entrance without a compositor 'hiccup'
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup environment
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 3. Define Options
Power_profile="󰓅  Power profile"
Power_Actions="󰐥  Action"
Services="󱖨  Services"
Processes="󰒓  Processes"

SYSTEM_OPTIONS="$Power_Actions\n$Power_profile\n$Processes\n$Services"

# 4. Launch Rofi
SYSTEM_CHOICE=$(echo -e "$SYSTEM_OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 4; }' \
    -theme-str 'entry { placeholder: "System..."; horizontal-align: 0.0; }')

# 5. Exit Check
[[ -z "$SYSTEM_CHOICE" ]] && exit 0
pkill rofi

# 6. Action Logic (Asynchronous & Detached)
# We remove all manual 'sleep 0.1' delays.
case "$SYSTEM_CHOICE" in
    "$Power_profile") "$CURRENT_DIR/power-profile.sh" & ;;
    "$Power_Actions") "$HOME/.config/Zenith/scripts/rofi_menu/powermenu.sh" & ;;
    "$Services")      "$CURRENT_DIR/services.sh" & ;; 
    "$Processes")     "$CURRENT_DIR/processes.sh" & ;;  
esac

disown
exit 0