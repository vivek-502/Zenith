#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Bypasses the disk write to save CPU cycles for the package list generation
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Get Package Lists (Optimized)
# We do this after the animation trigger so Rofi is ready to pop up immediately
INSTALLED_PACKAGES=$(pacman -Qq | sort)
AVAILABLE_PACKAGES=$(pacman -Slq | sort)

# 3. Filter for uninstalled packages
UNINSTALLED_PACKAGES=$(comm -13 <(echo "$INSTALLED_PACKAGES") <(echo "$AVAILABLE_PACKAGES"))

# 4. Open Rofi to select package(s)
SELECTED_PKGS=$(echo "$UNINSTALLED_PACKAGES" | rofi -dmenu -i -multi-select \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'window { width: 35%; }' \
    -theme-str 'listview { lines: 7; }' \
    -theme-str 'entry { placeholder: "SeZenith Packages to Install..."; }' \
    -p "Install")

# 5. Exit if nothing selected
[[ -z "$SELECTED_PKGS" ]] && exit 0
pkill rofi

# 6. Format selection
TARGETS=$(echo "$SELECTED_PKGS" | xargs)

# 7. Open Kitty to perform the installation (Asynchronous)
# We use '&' and 'disown' to ensure Rofi closes completely before Kitty opens.
# This prevents 'Keyboard Focus' conflicts between Rofi and the terminal.
kitty --class floating-terminal --title "Package Manager" sh -c "
    echo 'Preparing to install: $TARGETS'
    echo '-----------------------------------'
    sudo pacman -S --noconfirm $TARGETS
    echo '-----------------------------------'
    echo 'Installation completed. Press Enter to close...'
    read
" &

disown
exit 0