#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Direct injection prevents the 'stutter' while Rofi is open
hyprctl keyword source "$HOME/.config/rofi/animations/Walker_anim.conf"

# 2. Define file paths
CONFIG_FILE="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/dark-theme/env.sh"
CONFIG_FILE_2="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/light-theme/env.sh"
CSS_FILE="$HOME/.config/Zenith/current/theme/swaync.css"
CSS_FILE_2="$HOME/.config/Zenith/current/theme/swayosd.css"
UPDATING_LINE="SWAY_BG_OP"

# 3. Check if the environment configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    notify-send -a "System" "Error" "Configuration file not found!"
    exit 1
fi

# 4. Extract current values for the UI
current_alpha=$(grep -E "@define-color background rgba" "$CSS_FILE" | head -n 1 \
    | sed -E 's/.*rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,[[:space:]]*([0-9.]+)\).*/\1/')

line=$(grep "$UPDATING_LINE" "$CONFIG_FILE")
current_value=$(echo "$line" | awk -F '=' '{print $2}')

# 5. Launch Rofi for input
new_value=$(echo "$current_value" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'window { width: 350px; }' \
    -theme-str 'listview { lines: 0; }' \
    -theme-str 'entry { placeholder: "Enter value (0.0 to 1.0)"; }' \
    -p "Current: $current_alpha")

# 6. Function to validate opacity value
function is_valid_opacity {
    [[ $1 =~ ^0(\.[0-9]+)?|1(\.0+)?$ ]]
}

# 7. Action Logic
if [[ -n "$new_value" ]]; then
    if is_valid_opacity "$new_value"; then
        # Update the BACKGROUND_OPACITY line in environment files
        sed -i "/^$UPDATING_LINE/s/.*/$UPDATING_LINE=$new_value/" "$CONFIG_FILE"
        sed -i "/^$UPDATING_LINE/s/.*/$UPDATING_LINE=$new_value/" "$CONFIG_FILE_2"

        # Update SwayNC background and background-alt
        sed -i -E "s/(@define-color[[:space:]]+background[[:space:]]+rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\2/" "$CSS_FILE"
        sed -i -E "s/(@define-color[[:space:]]+background-alt[[:space:]]+rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\2/" "$CSS_FILE"

        # Update SwayOSD background
        sed -i -E "s/(@define-color[[:space:]]+background[[:space:]]+rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\2/" "$CSS_FILE_2"

        # 8. Restart services (Backgrounded and Detached)
        # We kill them aggressively and restart them silently
        pkill swayosd-server 2>/dev/null
        pkill swaync 2>/dev/null
        
        # Give a small buffer for the daemons to close properly
        sleep 0.4

        swayosd-server --style ~/.config/swayosd/style.css >/dev/null 2>&1 &
        swaync >/dev/null 2>&1 &

        notify-send -a "System" "OSD & Notification Opacity Updated" "Set to: $new_value"
    else
        notify-send -a "System" "Invalid Input" "Please enter a value between 0.0 and 1.0."
    fi
fi

disown
exit 0