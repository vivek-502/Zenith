#!/usr/bin/env bash

# 1. Injection
# Since we are restarting multiple bars and daemons, RAM-only injection
# is the only way to keep the UI from flickering while the files are written.
hyprctl keyword source "$HOME/.config/rofi/animations/Walker_anim.conf"

# 2. File Paths & Lines
ENV_DARK="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/dark-theme/env.sh"
ENV_LIGHT="$HOME/.config/Zenith/scripts/theme-with-wallpaper-maker/light-theme/env.sh"
KITTY_CONF="$HOME/.config/kitty/kitty.conf"

GTK_CSS="$HOME/.config/Zenith/current/theme/gtk.css"
SWAYOSD_CSS="$HOME/.config/Zenith/current/theme/swayosd.css"
ROFI_RASI="$HOME/.config/Zenith/current/theme/config.rasi"
SWAYNC_CSS="$HOME/.config/Zenith/current/theme/swaync.css"
WAYBAR_CSS="$HOME/.config/Zenith/current/theme/waybar.css"

# 3. Input UI
new_value=$(rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { enabled: true; children: [ "entry" ]; }' \
    -theme-str 'window { width: 350px; }' \
    -theme-str 'listview { lines: 0; }' \
    -theme-str 'entry { placeholder: "Enter Total Opacity (0.0 - 1.0)"; }' \
    -p "Global")

# 4. Validation
[[ -z "$new_value" ]] && exit 0
if [[ ! $new_value =~ ^0(\.[0-9]+)?|1(\.0+)?$ ]]; then
    notify-send -a "System" "Invalid Input" "Please enter a value between 0.0 and 1.0."
    exit 1
fi

# 5. The Massive SED Operations (Disk Writes)
# Update Environment Files
for env in "$ENV_DARK" "$ENV_LIGHT"; do
    sed -i "/^GTK_BG_OP/s/.*/GTK_BG_OP=$new_value/" "$env"
    sed -i "/^ROFI_BG_OP/s/.*/ROFI_BG_OP=$new_value/" "$env"
    sed -i "/^SWAY_BG_OP/s/.*/SWAY_BG_OP=$new_value/" "$env"
    sed -i "/^WAYBAR_BG_OP/s/.*/WAYBAR_BG_OP=$new_value/" "$env"
done

# GTK Styles
sed -i -E "s/(@define-color (window|sidebar)_bg_color rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\3/g" "$GTK_CSS"

# Kitty
sed -i "/^background_opacity/s/.*/background_opacity $new_value/" "$KITTY_CONF"

# Rofi
sed -i -E "s|(^[[:space:]]*background:[[:space:]]*rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)|\1$new_value\2|" "$ROFI_RASI"

# SwayNC & SwayOSD
sed -i -E "s/(@define-color[[:space:]]+background(-alt)?[[:space:]]+rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\3/g" "$SWAYNC_CSS"
sed -i -E "s/(@define-color[[:space:]]+background[[:space:]]+rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\2/" "$SWAYOSD_CSS"

# Waybar
sed -i -E "s/(@define-color background rgba\([0-9]+,[[:space:]]*[0-9]+,[[:space:]]*[0-9]+,)[[:space:]]*[0-9.]+(\);)/\1$new_value\2/" "$WAYBAR_CSS"

# 6. Service Refresh (Atomic Cluster)
(
    # Restart OSD & Notifications
    
    swaync >/dev/null 2>&1 &
    
    # Restart Waybar
    killall waybar && waybar >/dev/null 2>&1 &
    
    # Reload Kitty & Close Nautilus
    kill -USR1 $(pgrep kitty) 2>/dev/null
    killall -9 nautilus 2>/dev/null
) &

notify-send -a "System" "Global Opacity Applied" "Entire system set to: $new_value"

disown
exit 0