#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Direct injection avoids the disk-write race condition

hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Get current profile for the UI
CURRENT=$(powerprofilesctl get)

# 3. Define options
SAVER="󰌪  Power-saver"
BALANCED="󰘚  Balanced"
PERF="󰓅  Performance"
Power_OPTIONS="$SAVER\n$BALANCED\n$PERF"

# 4. Launch Rofi
# We use the -class flag just in case you want to target it later, 
# but the 'keyword' above does the heavy lifting.
power_CHOICE=$(echo -e "$Power_OPTIONS" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'inputbar { children: [ "entry" ]; }' \
    -theme-str 'listview { lines: 3; }' \
    -theme-str 'entry { placeholder: "Current: '$CURRENT'"; cursor-width: 0; horizontal-align: 0.5; }' \
    -mesg "POWER PROFILE  |  CURRENT: $CURRENT")

# 5. Exit Check
[[ -z "$power_CHOICE" ]] && exit 0
pkill rofi

# 6. Action Logic (Asynchronous & Detached)
# We use '&' so the script finishes immediately and Rofi closes 
# while the power daemon processes the change.
case "$power_CHOICE" in
    "$SAVER")
        powerprofilesctl set power-saver && \
        notify-send -a "System" "Power Mode" "Power Saver Activated" &
        ;;
    "$BALANCED")
        powerprofilesctl set balanced && \
        notify-send -a "System" "Power Mode" "Balanced Activated" &
        ;;
    "$PERF")
        powerprofilesctl set performance && \
        notify-send -a "System" "Power Mode" "Performance Activated" &
        ;;
esac

disown
exit 0