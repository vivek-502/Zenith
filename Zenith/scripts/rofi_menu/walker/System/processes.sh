#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Direct injection prevents the 'Race Condition' freeze while sorting processes

hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Get user processes (Optimized)
# Using -o comm,%cpu,%mem and sorting by CPU usage
PROC_LIST=$(ps -u "$USER" -o comm,%cpu,%mem --sort=-%cpu --no-headers | awk '{printf "%-20s  CPU: %s%%  MEM: %s%%\n", $1, $2, $3}')

# 3. Launch Rofi
SEL_PROC=$(echo -e "$PROC_LIST" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'window { width: 500px; }' \
    -theme-str 'listview { lines: 10; }' \
    -theme-str 'entry { placeholder: "Search process to kill..."; }' \
    -p "Kill")

# 4. Extract the process name
PROC_NAME=$(echo "$SEL_PROC" | awk '{print $1}')

# 5. Logic: Kill and Refresh
if [[ -n "$PROC_NAME" ]]; then
    # Force kill and send notification immediately
    pkill -9 -x "$PROC_NAME" &
    notify-send -a "Process Manager" "Force killed: $PROC_NAME" -i system-error &
    
    # Refresh the list automatically without re-running the animation logic
    # We use a slight delay so the process has time to disappear from 'ps'
    sleep 0.4
    exec "$0"
fi

disown
exit 0