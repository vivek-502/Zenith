#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# This ensures Rofi opens smoothly while we parse the CSS files
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Define file paths
CONFIG_FILE="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/dark-theme/env.sh"
CONFIG_FILE_2="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/light-theme/env.sh"
CSS_FILE="$HOME/.config/Zenith/current/theme/gtk.css"
UPDATING_LINE="GTK_BG_OP"

# 3. Validation Check
if [[ ! -f "$CONFIG_FILE" || ! -f "$CSS_FILE" ]]; then
    notify-send "Error" "Configuration or CSS file not found!"
    exit 1
fi

# 4. Extract current values for the UI
# Extract current alpha from window_bg_color
current_alpha=$(grep -E "@define-color window_bg_color rgba" "$CSS_FILE" \
    | sed -E 's/.*rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,[[:space:]]*([0-9.]+)\).*/\1/')

# Extract the current opacity value from env.sh
line=$(grep "$UPDATING_LINE" "$CONFIG_FILE")
current_value=$(echo "$line" | awk -F '=' '{print $2}')

# 5. Launch Rofi for input
new_value=$(echo "$current_value" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'window { width: 350px; }' \
    -theme-str 'listview { lines: 0; }' \
    -theme-str 'entry { placeholder: "Enter opacity (0.0 - 1.0)"; }' \
    -p "Current Alpha: $current_alpha")

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

        # Replace alpha values in GTK CSS (Window and Sidebar)
        sed -i -E \
            "s/(@define-color window_bg_color rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\2/" \
            "$CSS_FILE"
        sed -i -E \
            "s/(@define-color sidebar_bg_color rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\2/" \
            "$CSS_FILE"

        # Refresh Nautilus and notify
        killall -9 nautilus 2>/dev/null
        notify-send -a "System" "Opacity Updated" "Set $UPDATING_LINE to: $new_value"
    else
        notify-send -a "System" "Invalid Input" "Please enter a value between 0.0 and 1.0."
    fi
fi

disown
exit 0