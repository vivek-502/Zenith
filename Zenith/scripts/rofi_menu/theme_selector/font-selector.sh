#!/usr/bin/env bash

# 1. RAM Injection
# Launch the menu instantly. No disk-write 'hiccup' before searching fonts.
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Get font families
# Using -f1 to ensure we get the primary name for the config files
FONTS=$(fc-list : family | cut -d, -f1 | sort -u)

# 3. Launch Rofi
SELECTED_FONT=$(echo "$FONTS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'entry { placeholder: "Search Fonts..."; }')

# 4. Exit Check
[[ -z "$SELECTED_FONT" ]] && exit 0
pkill rofi

# 5. Apply to GTK (Direct System Call)
gsettings set org.gnome.desktop.interface font-name "$SELECTED_FONT 11"
gsettings set org.gnome.desktop.interface document-font-name "$SELECTED_FONT 11"
gsettings set org.gnome.desktop.interface monospace-font-name "$SELECTED_FONT 11"

# 6. Rewrite Config Files (The "Nuke" Phase)
# Using here-strings (<<<) or simple redirects is cleaner than 'echo | cat'
cat > "$HOME/.config/kitty/font.conf" <<EOF
# Font
font_family      family="$SELECTED_FONT"
EOF

cat > "$HOME/.config/waybar/font.css" <<EOF
* { font-family: '$SELECTED_FONT'; }
EOF

cat > "$HOME/.config/rofi/font.rasi" <<EOF
configuration {
    font: "$SELECTED_FONT 10";
}
EOF

cat > "$HOME/.config/swaync/font.css" <<EOF
* { font-family: '$SELECTED_FONT'; }
EOF

# 7. Refresh Services (Silent & Backgrounded)
(
    # Signal Waybar & SwayNC to reload CSS without restarting
    pkill -SIGUSR2 waybar
    pkill -SIGUSR2 swaync
    
    # Reload Kitty
    kill -USR1 $(pgrep kitty) 2>/dev/null
    
    # Force GTK settings to take effect
    killall xdg-desktop-portal-gtk 2>/dev/null
) &

notify-send -a "Appearance" "Font Applied" "System font set to: $SELECTED_FONT"

disown
exit 0
