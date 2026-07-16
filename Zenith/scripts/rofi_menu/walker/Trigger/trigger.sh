#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# This avoids the disk-write that causes Hyprland to lag during a screenshot
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup environment
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 3. Define Options
Screenshot="󰄄  Screenshot"
Color="󰈋  Color"
Clipboard="󱘝  Clipboard"
Notes="󰠮  Notes"
Waybar="▌  Waybar position" 
Workspace="󰕮  Workspaces"
Mute_window="🖳 Mute window"
OCR4Linux="⛶  OCR4Linux"

CAPTURE_OPTIONS="$Color\n$Clipboard\n$Mute_window\n$Notes\n$OCR4Linux\n$Screenshot\n$Waybar\n$Workspace"

# 4. Launch Rofi Main Menu
CAPTURE_CHOICE=$(echo -e "$CAPTURE_OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 8; }' \
    -theme-str 'entry { placeholder: "Select..."; }')

# 5. Exit Check
[[ -z "$CAPTURE_CHOICE" ]] && exit 0
pkill rofi

# 6. Action Logic (Asynchronous & Direct)
case "$CAPTURE_CHOICE" in
    "$Screenshot") 
        (sleep 0.2 && hyprshot -m region) & ;;
        
    "$Color") 
        (sleep 0.2 && hyprpicker | wl-copy && notify-send "Hyprpicker" "Color copied to clipboard") & ;;
        
    "$Clipboard") 
        ~/.config/Zenith/scripts/rofi_menu/clipboard.sh & ;;

    "$Notes") 
        hyprctl dispatch exec "[float; size 600 400; center] kitty sh -c 'nano ~/Documents/notes.txt'" & ;;

    "$Waybar") 
        ~/.config/Zenith/scripts/switch-waybar-pos.sh & ;;

    "$Workspace")
	    ~/.config/Zenith/scripts/workspace/workspace.sh & ;;

    "$Mute_window")
        $CURRENT_DIR/mute-window.sh & ;;
    "$OCR4Linux")
        $CURRENT_DIR/OCR4Linux.sh & ;;
esac

disown
exit 0
