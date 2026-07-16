#!/usr/bin/env bash

# 1. Update the animation in RAM instantly (No Disk I/O, No Freeze)
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup paths
export PATH_SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 3. Define Icons (Nerd Font)
ICON_APPS="󰀻  Apps"
ICON_THEME="󰏘  Appearance"
ICON_LEARN="📋︎ Learn"
ICON_INSTALL="🗳 Install"
ICON_REMOVE="󱆿  Remove"
ICON_TRIGGER="󰄀  Trigger"
ICON_SYS="󰒓  System"
ICON_SPEC="✯ Special"

OPTIONS="$ICON_APPS\n$ICON_THEME\n$ICON_LEARN\n$ICON_INSTALL\n$ICON_REMOVE\n$ICON_TRIGGER\n$ICON_SYS\n$ICON_SPEC"

# 4. Launch Rofi
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 8; }' \
    -theme-str 'entry { placeholder: "SeZenith..."; }')

# 5. Immediate Exit Check
[[ -z "$CHOICE" ]] && exit 0
pkill rofi

# 6. Action Logic (Asynchronous & Detached)
# We exit this script immediately so Rofi releases the keyboard grab.
case "$CHOICE" in
    "$ICON_APPS")    rofi -show drun & ;;
    "$ICON_THEME")   "$PATH_SCRIPTS/Appearence/appearance.sh" & ;;
    "$ICON_TRIGGER") "$PATH_SCRIPTS/Trigger/trigger.sh" & ;;
    "$ICON_INSTALL") "$PATH_SCRIPTS/Install/install.sh" & ;;
    "$ICON_REMOVE")  "$PATH_SCRIPTS/Remove/package-remove.sh" & ;;
    "$ICON_LEARN")   "$PATH_SCRIPTS/Learn/learn.sh" & ;;
    "$ICON_SYS")     "$PATH_SCRIPTS/System/system.sh" & ;;
    "$ICON_SPEC")    "$PATH_SCRIPTS/Special/special.sh" & ;;
esac

disown
exit 0
