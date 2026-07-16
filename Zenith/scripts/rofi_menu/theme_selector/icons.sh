#!/usr/bin/env bash

# 1. RAM Injection
# Launch the menu instantly. Bypassing the disk prevents the 'walker' 
# animation from stuttering during the icon indexing loop below.
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

ROFI_THEME="$HOME/.config/rofi/walker.rasi"
ICON_DIRS=("/usr/share/icons" "$HOME/.icons")
entries=""

# 2. Collect Icon Themes (Optimized Loop)
for dir in "${ICON_DIRS[@]}"; do
  [[ -d "$dir" ]] || continue

  for theme in "$dir"/*; do
    [[ -d "$theme" && -f "$theme/index.theme" ]] || continue
    
    # Fast check: skip cursor-only themes
    grep -q "^Directories=" "$theme/index.theme" || continue

    name=$(basename "$theme")
    preview=""

    # Look for a representative icon for the Rofi preview
    for icon_sub in "apps/48" "apps/64" "apps/scalable" "places/48" "mimetypes/48"; do
      if [[ -d "$theme/$icon_sub" ]]; then
        preview=$(find "$theme/$icon_sub" -maxdepth 1 -type f \( -name "*.png" -o -name "*.svg" \) | head -n1)
        [[ -n "$preview" ]] && break
      fi
    done

    if [[ -n "$preview" ]]; then
      entries+="$name\0icon\x1f$preview\n"
    else
      entries+="$name\n"
    fi
  done
done

# 3. Rofi Menu
SELECTED=$(echo -e "$entries" | rofi -dmenu -i \
            -theme "$ROFI_THEME" \
            -theme-str 'inputbar { children: [ "entry" ]; }' \
            -theme-str 'listview { lines: 7; }' \
            -theme-str 'entry { placeholder: "Select Icon Theme..."; }')

[[ -z "$SELECTED" ]] && exit 0
pkill rofi

# 4. Apply & Background Tasks
# Apply via GSettings (Instant D-Bus call)
gsettings set org.gnome.desktop.interface icon-theme "$SELECTED"

# Run the heavy cache update in the background so the script finishes immediately
(
  if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    for dir in "${ICON_DIRS[@]}"; do
      if [[ -d "$dir/$SELECTED" ]]; then
        gtk-update-icon-cache -q -f "$dir/$SELECTED" >/dev/null 2>&1
      fi
    done
  fi
  notify-send -a "Appearance" "Icon Theme Applied" "Switched to: $SELECTED"
) &

disown
exit 0