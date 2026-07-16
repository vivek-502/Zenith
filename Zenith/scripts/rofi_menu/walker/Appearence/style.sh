
#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# This covers both the main style menu and the sub-menus
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Setup environment
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STYLE_SCRIPTS="$HOME/.config/Zenith/scripts/rofi_menu/style-selector"

# 3. Define Main Options
Overall_look="󰏘  Overall look"
Waybar="󰃟  Waybar Style"
Rofi="☰  Rofi Style"
Hyprlock="ꗃ    Hyprlock"

STYLE_OPTIONS="$Overall_look\n$Rofi\n$Waybar\n$Hyprlock"

# 4. Launch Main Rofi
STYLE_CHOICE=$(echo -e "$STYLE_OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 4; }' \
    -theme-str 'entry { placeholder: "Styles..."; }')

# 5. Exit Check
[[ -z "$STYLE_CHOICE" ]] && exit 0
pkill rofi

# 6. Main Logic
case "$STYLE_CHOICE" in
    "$Overall_look") 
        "$STYLE_SCRIPTS/main.sh" & ;;
        
    "$Waybar") 
        "$STYLE_SCRIPTS/waybar-style.sh" & ;;
        
    "$Hyprlock") 
        "$STYLE_SCRIPTS/hyprlock.sh" & ;;
        
    "$Rofi") 
        # Sub-menu Options
        App_launcher="󰀻  App Launcher"
        Power_menu="󰐥  Power menu"
        Theme_selector="󰏘  Theme selector"
        Walker="☰  Walker"

        ROFI_STYLE_OPTIONS="$App_launcher\n$Power_menu\n$Theme_selector\n$Walker"

        # Launch Sub-Rofi
        ROFI_STYLE_CHOICE=$(echo -e "$ROFI_STYLE_OPTIONS" | rofi -dmenu -i \
            -theme ~/.config/rofi/walker.rasi \
            -theme-str 'inputbar { children: [ "entry" ]; }' \
            -theme-str 'listview { lines: 4; }' \
            -theme-str 'entry { placeholder: "Rofi style..."; }')

        [[ -z "$ROFI_STYLE_CHOICE" ]] && exit 0

        case "$ROFI_STYLE_CHOICE" in
            "$App_launcher")   "$STYLE_SCRIPTS/app_launcher_style.sh" & ;;
            "$Power_menu")     "$STYLE_SCRIPTS/power_menu_style.sh" & ;;
            "$Theme_selector") "$STYLE_SCRIPTS/theme_selector_style.sh" & ;;
            "$Walker")         "$STYLE_SCRIPTS/walker_style.sh" & ;;
        esac 
    ;; 
esac

disown
exit 0
