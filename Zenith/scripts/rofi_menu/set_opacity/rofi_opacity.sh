#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Direct injection is way safer than 'cp' when doing multiple file edits
hyprctl keyword source "$HOME/.config/rofi/animations/Walker_anim.conf"

# 2. Define file paths
CONFIG_FILE="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/dark-theme/env.sh"
CONFIG_FILE_2="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/light-theme/env.sh"
CURRENT_FILE="$HOME/.config/Zenith/current/theme/config.rasi"
UPDATING_LINE="ROFI_BG_OP"

# 3. Validation Check
if [[ ! -f "$CONFIG_FILE" || ! -f "$CURRENT_FILE" ]]; then
    notify-send -a "System" "Error" "Rofi config or environment file not found!"
    exit 1
fi

# 4. Extract current values for the UI
# We grab the current value from the environment file for display
line=$(grep "$UPDATING_LINE" "$CONFIG_FILE")
current_value=$(echo "$line" | awk -F '=' '{print $2}')

# 5. Launch Rofi for input
new_value=$(echo "$current_value" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'window { width: 350px; }' \
    -theme-str 'listview { lines: 0; }' \
    -theme-str 'entry { placeholder: "Enter opacity (0.0 - 1.0)"; }' \
    -p "Rofi Opacity (Current: $current_value)")

# 6. Function to validate opacity value
function is_valid_opacity {
    [[ $1 =~ ^0(\.[0-9]+)?|1(\.0+)?$ ]]
}

# 7. Action Logic
if [[ -n "$new_value" ]]; then
    if is_valid_opacity "$new_value"; then
        # Update both environment files for the theme maker
        sed -i "/^$UPDATING_LINE/s/.*/$UPDATING_LINE=$new_value/" "$CONFIG_FILE"
        sed -i "/^$UPDATING_LINE/s/.*/$UPDATING_LINE=$new_value/" "$CONFIG_FILE_2"

        # Update the background alpha specifically in the Rofi .rasi file
        # We use | as a delimiter in sed because the line contains parentheses and commas
        sed -i -E \
            "s|(^[[:space:]]*background:[[:space:]]*rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)|\1$new_value\2|" \
            "$CURRENT_FILE"

        notify-send -a "System" "Rofi Opacity Updated" "Set $UPDATING_LINE to: $new_value"
    else
        notify-send -a "System" "Invalid Input" "Please enter a value between 0.0 and 1.0."
    fi
fi

disown
exit 0