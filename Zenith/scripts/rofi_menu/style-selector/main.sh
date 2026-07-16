#!/bin/bash


# Start the menu instantly without a disk-write 'hiccup'
hyprctl keyword source "$HOME/.config/rofi/animations/Walker_anim.conf"


# Paths
# Note: Added quotes around the path since "App launcher" has a space
STYLES_DIR="$HOME/.config/Zenith/styles"
ROFI_DIR="$HOME/.config/rofi"
WAYBAR_DIR="$HOME/.config/waybar"
HYPRLAND_DIR="$HOME/.config/hypr"
# SWAYNC_DIR="$HOME/.config/swaync"
ICON="󰏘" 

# 1. Ensure Styles Directory exists and isn't empty
if [ ! -d "$STYLES_DIR" ] || [ -z "$(ls -A "$STYLES_DIR")" ]; then
    notify-send "Error" "Styles directory is missing or empty!"
    exit 1
fi

# --- Updated: Dynamic Line Calculation (Max 7) ---
LINE_COUNT=$(ls -1 "$STYLES_DIR" | wc -l)

if [ "$LINE_COUNT" -gt 7 ]; then
    DISPLAY_LINES=7
elif [ "$LINE_COUNT" -eq 0 ]; then
    DISPLAY_LINES=1 # Safety fallback
else
    DISPLAY_LINES=$LINE_COUNT
fi
# ------------------------------------------------

# 2. Get folders and format for Rofi
# Using two spaces after icon for a cleaner look
OPTIONS=$(ls -1 "$STYLES_DIR" | sed "s/^/$ICON  /")

# 3. Launch Rofi
# Double quotes allow the $DISPLAY_LINES variable to be read
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i \
    -theme "$HOME/.config/rofi/walker.rasi" \
    -theme-str "listview { lines: $DISPLAY_LINES; }" \
    -theme-str 'entry { placeholder: "Select style..."; horizontal-align: 0.0; }' \
    )

# 4. Action Logic
if [ -n "$CHOICE" ]; then
    # Improved sed: This removes the ICON and any following whitespace safely
    STYLE_NAME=$(echo "$CHOICE" | sed "s/^$ICON *//")
    SELECTED_PATH="$STYLES_DIR/$STYLE_NAME"

    if [ -d "$SELECTED_PATH" ]; then

        get_waybar_position() {
            local file="$1"
            grep -oP '"position"\s*:\s*"\K[^"]+' "$file"
        }

        waybar_jsonc="$SELECTED_PATH/waybar/config.jsonc"

        waybar_position=$(get_waybar_position "$waybar_jsonc")

        echo > "$WAYBAR_DIR/position/.current_position" $waybar_position



        # Copy everything from the selected folder to ~/.config/rofi/
        rm -rf "$WAYBAR_DIR/position/"*
        rm -rf "$ROFI_DIR/animations/"*

        cp -rf "$SELECTED_PATH/waybar/". "$WAYBAR_DIR/"
        cp -rf "$SELECTED_PATH/rofi"/. "$ROFI_DIR/"
        cp -rf "$SELECTED_PATH/hyprland"/. "$HYPRLAND_DIR/"

        pkill waybar && waybar &
        sleep 0.5
        
        notify-send "Style selector" "Applied style: $STYLE_NAME" -i appearance
    else
        notify-send "Error" "Style folder not found: $STYLE_NAME"
    fi
fi

disown
exit 0
