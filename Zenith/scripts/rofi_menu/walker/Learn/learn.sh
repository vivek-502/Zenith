#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Direct injection prevents the 'Race Condition' that freezes the compositor
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup environment
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$HOME/.config/Zenith/scripts/rofi_menu"

# 3. Define Options
Keybinds="󰌌 Keybinds"

OPTIONS="$Keybinds"

# 4. Launch Rofi
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 1; }' \
    -theme-str 'entry { placeholder: "SeZenith..."; }')

# 5. Exit Check
[[ -z "$CHOICE" ]] && exit 0
pkill rofi

# 6. Action Logic (Asynchronous & Detached)
case "$CHOICE" in
    "$Keybinds") 
        "$SCRIPTS_DIR/keybindings.sh" & ;;
esac

disown
exit 0
