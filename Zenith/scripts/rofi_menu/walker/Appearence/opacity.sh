#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# This bypasses the disk and prevents the 'Race Condition' freeze.
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup environment
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPACITY_SCRIPTS="$HOME/.config/Zenith/scripts/rofi_menu/set_opacity"

# 3. Define Options
Whole_system="󰘵  Whole system"
Kitty="󰄛  Kitty"
GTK="󰟆  GTK"
Rofi="󰍉  Rofi"
Waybar="󰕮  Waybar"
Sway="󰖯  SwayNC (notification)"

STYLE_OPTIONS="$Whole_system\n$GTK\n$Kitty\n$Rofi\n$Waybar\n$Sway"

# 4. Launch Rofi
STYLE_CHOICE=$(echo -e "$STYLE_OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 6; }' \
    -theme-str 'entry { placeholder: "Styles..."; }')

# 5. Exit Check
[[ -z "$STYLE_CHOICE" ]] && exit 0
pkill rofi

# 6. Action Logic (Asynchronous & Detached)
# We remove all manual 'sleep 0.1' delays so the menu feels snappy.
case "$STYLE_CHOICE" in
    "$Whole_system") "$OPACITY_SCRIPTS/overall.sh" & ;;
    "$Kitty")        "$OPACITY_SCRIPTS/kitty_opacity.sh" & ;;
    "$GTK")          "$OPACITY_SCRIPTS/GTK_opacity.sh" & ;;
    "$Rofi")         "$OPACITY_SCRIPTS/rofi_opacity.sh" & ;;
    "$Waybar")       "$OPACITY_SCRIPTS/waybar_opacity.sh" & ;;
    "$Sway")         "$OPACITY_SCRIPTS/sway_opacity.sh" & ;;   
esac

disown
exit 0
