#!/usr/bin/env bash
set -euo pipefail

# 1. RAM Injection
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Collect Cursor Themes
ICON_DIRS=("/usr/share/icons" "$HOME/.icons" "$HOME/.local/share/icons")
entries=""

for dir in "${ICON_DIRS[@]}"; do
  [[ -d "$dir" ]] || continue
  for theme in "$dir"/*; do
    # A cursor theme must have a 'cursors' subdirectory
    if [[ -d "$theme/cursors" ]]; then
      entries+="$(basename "$theme")\n"
    fi
  done
done

# 3. Rofi Menu
SELECTED=$(echo -e "$entries" | sort -u | rofi -dmenu -i \
            -theme "$HOME/.config/rofi/walker.rasi" \
            -theme-str 'inputbar { children: [ "entry" ]; }' \
            -theme-str 'entry { placeholder: "Select Cursor..."; }' \
            -p "Select Cursor Theme")

[[ -z "$SELECTED" ]] && exit 0

# 4. Apply Instantly
hyprctl setcursor "$SELECTED" 24
gsettings set org.gnome.desktop.interface cursor-theme "$SELECTED"

# 5. Make Persistent (Update autostart.lua)
# This uses sed to find the 'setcursor' line and replace the theme name
AUTOSTART="$HOME/.config/hypr/autostart.lua"
sed -i "s/setcursor [^ ]*/setcursor $SELECTED/" "$AUTOSTART"

notify-send -a "Appearance" "Cursor Applied" "Changed to $SELECTED"
exit 0