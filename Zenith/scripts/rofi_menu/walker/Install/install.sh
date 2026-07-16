#!/usr/bin/env bash

# 1. Update the animation in RAM instantly (Direct command, no disk write)
# This uses your Walker_anim.conf specifically for this menu
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup environment
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 3. Define Options
Pacman="🗳︎  Pacman"
Yay="🗳︎  Yay"
OPTIONS="$Pacman\n$Yay"

# 4. Launch Rofi
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 2; }' \
    -theme-str 'entry { placeholder: "Select install medium..."; }')

# 5. Exit Check
[[ -z "$CHOICE" ]] && exit 0
pkill rofi

# 6. Action Logic (Asynchronous & Detached)
# Rofi closes immediately, then the installer launches
case "$CHOICE" in
    "$Pacman") 
        "$CURRENT_DIR/package-install-pacman.sh" & ;;
    "$Yay") 
        "$CURRENT_DIR/package-install-yay.sh" & ;;
esac

disown
exit 0