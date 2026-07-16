#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Direct injection prevents the 'stutter' while Rofi is open
hyprctl keyword source "$HOME/.config/rofi/animations/Walker_anim.conf"

# 2. Define file paths
CONFIG_FILE="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/dark-theme/env.sh"
CONFIG_FILE_2="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/light-theme/env.sh"
CURRENT_FILE="$HOME/.config/Zenith/current/theme/waybar.css"
CURRENT_FILE_2="$HOME/.config/Zenith/current/theme/gtk.css"
UPDATING_LINE="WAYBAR_BG_OP"

# 3. Check if files exist
if [[ ! -f "$CONFIG_FILE" || ! -f "$CURRENT_FILE" ]]; then
    notify-send -a "System" "Error" "Waybar config or environment file not found!"
    exit 1
fi

# 4. Extract current values for the UI
line=$(grep "$UPDATING_LINE" "$CONFIG_FILE")
current_value=$(echo "$line" | awk -F '=' '{print $2}')

# 5. Launch Rofi for input
new_value=$(echo "$current_value" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'window { width: 350px; }' \
    -theme-str 'listview { lines: 0; }' \
    -theme-str 'entry { placeholder: "Enter value (0.0 to 1.0)"; }' \
    -p "Waybar Alpha (Current: $current_value)")

# 6. Function to validate opacity value
function is_valid_opacity {
    [[ $1 =~ ^0(\.[0-9]+)?|1(\.0+)?$ ]]
}

# 7. Action Logic
if [[ -n "$new_value" ]]; then
    if is_valid_opacity "$new_value"; then
        # Update environment files
        sed -i "/^$UPDATING_LINE/s/.*/$UPDATING_LINE=$new_value/" "$CONFIG_FILE"
        sed -i "/^$UPDATING_LINE/s/.*/$UPDATING_LINE=$new_value/" "$CONFIG_FILE_2"

        # Update the Waybar CSS specifically
        sed -i -E "s/(@define-color background rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\2/" "$CURRENT_FILE"
        
        # Replace for nm-applet
        sed -i -E \
            "s/(@define-color nm_bg_color rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\2/" \
            "$CURRENT_FILE_2"
            

        # 8. Restart Waybar (Safe & Detached)
        # We use a background subshell to ensure Rofi closes before Waybar starts
        (killall waybar && sleep 0.2 && waybar) >/dev/null 2>&1 &

        notify-send -a "System" "Waybar Updated" "Set opacity to: $new_value"
    else
        notify-send -a "System" "Invalid Input" "Please enter a value between 0.0 and 1.0."
    fi
fi

disown
exit 0
