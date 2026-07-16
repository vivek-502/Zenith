#!/usr/bin/env bash

# 1. SETUP ENVIRONMENT
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$HOME/.config/Zenith/scripts/rofi_menu"

# 2. THE ANIMATION SWAP 
# We inject it once here. 
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 3. DEFINE OPTIONS
Background="󰸉  Background"
Cursor="⮞  Cursor"
hyprland="󰕮  Hyprland"
Font="󰛖  Font"
Live_background="󰑋  Live background"
icons_theme="󰏘  Icons"
Opacity="󰕮  Opacity"
theme_with_wallpaper="󰏘  Theme by wallpaper"
Styles="󰔎  Style"

Appearance_options="$Background\n$Cursor\n$Font\n$hyprland\n$icons_theme\n$Live_background\n$Opacity\n$Styles\n$theme_with_wallpaper"

# 4. LAUNCH ROFI
Appearances_CHOICE=$(echo -e "$Appearance_options" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 9; }' \
    -theme-str 'entry { placeholder: "Appearance..."; }')

# 5. EXIT CHECK
[[ -z "$Appearances_CHOICE" ]] && exit 0

# 6. THE FIX: Clear the Rofi focus BEFORE calling the next script
# This "hides" the menu so the next script doesn't fight for the screen
pkill rofi 

# 7. ACTION LOGIC 
case "$Appearances_CHOICE" in
    "$hyprland")                 "$SCRIPTS_DIR/walker/Appearence/hyprland.sh" & ;;
    "$Cursor")               "$SCRIPTS_DIR/theme_selector/cursor.sh";;
    "$Background")           "$SCRIPTS_DIR/theme_selector/choose-background.sh" & ;;
    "$Font")                 "$SCRIPTS_DIR/theme_selector/font-selector.sh" & ;;
    "$icons_theme")          "$SCRIPTS_DIR/theme_selector/icons.sh" & ;;
    "$Live_background")      "$SCRIPTS_DIR/theme_selector/live-wallpaper.sh" & ;;
    "$Opacity")              "$CURRENT_DIR/opacity.sh" & ;;
    "$theme_with_wallpaper") "$CURRENT_DIR/theme_by_wallpaper.sh" & ;;
    "$Styles")               "$CURRENT_DIR/style.sh" & ;;
esac

disown
exit 0
