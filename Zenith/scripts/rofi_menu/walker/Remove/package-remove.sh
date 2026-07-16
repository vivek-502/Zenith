#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Direct injection avoids the disk-write race condition
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Get list of installed packages (sorted)
# Querying the local database is fast and safe here
PACKAGES=$(pacman -Qq | sort)

# 3. Open Rofi to select package(s)
SELECTED_PKGS=$(echo "$PACKAGES" | rofi -dmenu -i -multi-select \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'window { width: 35%; }' \
    -theme-str 'listview { lines: 7; }' \
    -theme-str 'entry { placeholder: "Search Packages to Remove..."; }' \
    -p "Uninstall")

# 4. Exit if nothing selected
[[ -z "$SELECTED_PKGS" ]] && exit 0
pkill rofi

# 5. Format the selection for the command
TARGETS=$(echo "$SELECTED_PKGS" | xargs)

# 6. Open Kitty to perform the removal (Asynchronous & Detached)
# We ensure Rofi is dead so the 'sudo' prompt in Kitty gets immediate focus
kitty --class floating-terminal --title "Package Manager" sh -c "
    echo 'Preparing to remove: $TARGETS'
    echo '-----------------------------------'
    sudo pacman -Rns $TARGETS
    echo '-----------------------------------'
    echo 'Press Enter to close...'
    read
" &

disown
exit 0