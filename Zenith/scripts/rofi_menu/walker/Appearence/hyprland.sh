#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup environment
SCRIPT_DIR="$HOME/.config/Zenith/scripts/rofi_menu/hyprland"

# 3. Define Options
Blur="󰔟  Blur Strength"
Rounding="󰁙  Rounding"
Border="󰆑  Border Size"
GapsIn="󰈯  Gaps In"
GapsOut="󰈰  Gaps Out"

OPTIONS="$Blur\n$Rounding\n$Border\n$GapsIn\n$GapsOut"

# 4. Launch Rofi
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i \
    -config ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 5; }' \
    -theme-str 'entry { placeholder: "Hyprland Tweaks..."; }' \
    -p "Tweak")

# 5. Exit Check
[[ -z "$CHOICE" ]] && exit 0

# 6. Action Logic
case "$CHOICE" in
    "$Blur")     "$SCRIPT_DIR/blur-value.sh" & ;;
    "$Rounding") "$SCRIPT_DIR/rounding-corners.sh" & ;;
    "$Border")   "$SCRIPT_DIR/border.sh" & ;;
    "$GapsIn")   "$SCRIPT_DIR/gaps_in.sh" & ;;
    "$GapsOut")  "$SCRIPT_DIR/gaps_out.sh" & ;;
esac

disown
exit 0