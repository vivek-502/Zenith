f#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# No disk write means no potential for the Acer system to hang.
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup environment
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 3. Define Options
Anime="󰄄  Watch Anime"
Download_vid="📽 Dowload video"

OPTIONS="$Anime\n$Download_vid"

# 4. Launch Rofi
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 2; }' \
    -theme-str 'entry { placeholder: "Select..."; }')

# 5. Exit Check
[[ -z "$CHOICE" ]] && exit 0
pkill rofi

# 6. Action Logic (Asynchronous & Detached)
# We remove the manual 'sleep' delays entirely.
case "$CHOICE" in
    "$Anime") "$HOME/.config/Zenith/scripts/special/watch-anime.sh" & ;;
    "$Download_vid") "$HOME/.config/Zenith/scripts/special/video-downloader.sh" & ;;
esac

disown
exit 0
