#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Bypasses the disk and the 'config reload' 
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Get Package Lists (Optimized)
# Note: yay -Slq can be slow on some systems; direct injection is much safer here
INSTALLED_PACKAGES=$(yay -Qq | sort)
AVAILABLE_PACKAGES=$(yay -Slq | sort)

# 3. Filter for uninstalled packages
UNINSTALLED_PACKAGES=$(comm -13 <(echo "$INSTALLED_PACKAGES") <(echo "$AVAILABLE_PACKAGES"))

# 4. Open Rofi to select package(s)
SELECTED_PKGS=$(echo "$UNINSTALLED_PACKAGES" | rofi -dmenu -i -multi-select \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'window { width: 35%; }' \
    -theme-str 'listview { lines: 7; }' \
    -theme-str 'entry { placeholder: "Search AUR/Repo Packages..."; }' \
    -p "Install")

# 5. Exit if nothing selected
[[ -z "$SELECTED_PKGS" ]] && exit 0
pkill rofi

# 6. Format selection
TARGETS=$(echo "$SELECTED_PKGS" | xargs)

# 7. Open Kitty to perform the installation (Asynchronous & Detached)
# We ensure Rofi is dead before the AUR helper starts its work
kitty --class floating-terminal --title "Yay Package Manager" sh -c "
    echo 'Preparing to install from AUR/Repos: $TARGETS'
    echo '-----------------------------------'
    yay -S --noconfirm $TARGETS
    echo '-----------------------------------'
    echo 'Installation completed. Press Enter to close...'
    read
" &

disown
exit 0