#!/usr/bin/env bash

# 1. Injection (RAM-only)
# Start the menu instantly without a disk-write 'hiccup'
hyprctl keyword source "$HOME/.config/rofi/animations/Walker_anim.conf"

# Paths
STYLES_DIR="$HOME/.config/Zenith/styles"
EXTRA_STYLES_DIR="$HOME/.config/Zenith/extra-styles/rofi/walker"
TARGET_DIR="$HOME/.config/rofi"
ICON="󰏘"

# 2. Validation & Line Calculation
# Collect all folders from both directories, suppressing errors if one doesn't exist, and remove duplicates
AVAILABLE_STYLES=$( (ls -1 "$STYLES_DIR" 2>/dev/null; ls -1 "$EXTRA_STYLES_DIR" 2>/dev/null) | sort -u )

if [[ -z "$AVAILABLE_STYLES" ]]; then
    notify-send -a "System" "Error" "No styles found in either directory!"
    exit 1
fi

LINE_COUNT=$(echo "$AVAILABLE_STYLES" | wc -l)
DISPLAY_LINES=$(( LINE_COUNT > 7 ? 7 : (LINE_COUNT == 0 ? 1 : LINE_COUNT) ))

# 3. Format Options
OPTIONS=$(echo "$AVAILABLE_STYLES" | sed "s/^/$ICON  /")

# 4. Launch Rofi
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i \
    -theme "$TARGET_DIR/walker.rasi" \
    -theme-str "listview { lines: $DISPLAY_LINES; }" \
    -theme-str 'entry { placeholder: "Select Walker style..."; }')

# 5. Action Logic
if [[ -n "$CHOICE" ]]; then
    # Clean the icon from the choice
    STYLE_NAME=$(echo "$CHOICE" | sed "s/^$ICON *//")
    
    # Determine which base directory the selected style belongs to and copy accordingly
    if [[ -d "$STYLES_DIR/$STYLE_NAME" ]]; then
        SELECTED_PATH="$STYLES_DIR/$STYLE_NAME"
           
        # Structure for main styles directory
        cp -rf "$SELECTED_PATH/rofi/walker.rasi" "$TARGET_DIR/"
        cp -rf "$SELECTED_PATH/rofi/animations/Walker_anim.conf" "$TARGET_DIR/animations/"
        
    elif [[ -d "$EXTRA_STYLES_DIR/$STYLE_NAME" ]]; then
        SELECTED_PATH="$EXTRA_STYLES_DIR/$STYLE_NAME"
        
        # Flat structure for extra-styles directory
        cp -rf "$SELECTED_PATH/walker.rasi" "$TARGET_DIR/"
        cp -rf "$SELECTED_PATH/Walker_anim.conf" "$TARGET_DIR/animations/"
        
    else
        notify-send -a "System" "Error" "Style path not found!"
        exit 1
    fi
    
    notify-send -a "Appearance" "Rofi Style Applied" "Switched to: $STYLE_NAME"
fi

disown
exit 0