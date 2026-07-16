#!/usr/bin/env bash

# 1. RAM Animation Injection
# We use quotes and a cleaner path call
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup environment
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 3. Define Options
dark_theme="󰔎  Dark"
light_theme="󰔎  Light"
WALL_OPTIONS="$dark_theme\n$light_theme"

# 4. Launch Rofi
CHOICE=$(echo -e "$WALL_OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 2; }' \
    -theme-str 'entry { placeholder: "Theme Mode Selection..."; }')

# 5. Exit Check
[[ -z "$CHOICE" ]] && exit 0

# 6. ACTION LOGIC 
# KILL Rofi immediately so the next handler.sh can take over the screen focus
pkill rofi

case "$CHOICE" in
    "$dark_theme")
        # Change the animation for the next menu in the sequence
        hyprctl eval "dofile('$HOME/.config/rofi/animations/Theme_selector_anim.lua')"
        # The background script handles its own timing now
        "$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/dark-theme/handler.sh" &
        ;;
    "$light_theme") 
        hyprctl eval "dofile('$HOME/.config/rofi/animations/Theme_selector_anim.lua')"
        "$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/light-theme/handler.sh" &
        ;;
esac

disown
exit 0