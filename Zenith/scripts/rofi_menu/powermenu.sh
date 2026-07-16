#!/bin/bash

# 1. RAM Injection
# Start the selector instantly. No disk-write here, because we're about 
# to do heavy IO operations below.
hyprctl eval "dofile('$HOME/.config/rofi/animations/Power_menu_anim.lua')"
killall -SIGUSR1 waybar

# Robust Battery Detection
BAT=$(ls /sys/class/power_supply | grep BAT | head -n 1)
if [ -n "$BAT" ]; then
    BAT_STAT=$(cat /sys/class/power_supply/$BAT/status)
    BAT_PERC=$(cat /sys/class/power_supply/$BAT/capacity)
else
    BAT_STAT="N/A"
    BAT_PERC="0"
fi

# Get Uptime (Formatted)
UPTIME=$(uptime -p | sed 's/up //')

# Icons
LOCK="󰌾"
HIBERNATE="󰤄"
RESTART="󰜉"
SHUTDOWN=""
LOGOUT="󰍃"

OPTIONS="$LOCK\n$HIBERNATE\n$RESTART\n$SHUTDOWN\n$LOGOUT"

# Launch Rofi
# The -markup-rows allows us to use bold/colors in the message if needed
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu \
    -p "Power" \
    -mesg " Uptime: $UPTIME" \
    -theme ~/.config/rofi/powermenu.rasi)

case "$CHOICE" in
    "$LOCK") hyprlock || swaylock ;;
    "$HIBERNATE") systemctl hibernate ;;
    "$RESTART") systemctl reboot ;;
    "$SHUTDOWN") systemctl poweroff ;;
    "$LOGOUT") hyprctl dispatch exit ;;
esac

killall -SIGUSR1 waybar
