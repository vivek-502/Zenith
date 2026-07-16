#!/usr/bin/env bash

# 1. Update the animation in RAM instantly
# Direct injection is essential here to prevent the freeze during list generation
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# 2. Get ALL loaded services (Active, Inactive, and Failed)
# This one-liner replaces your slow 'while' loop and captures every service.
MENU_LIST=$(systemctl list-units --type=service --all --no-pager --no-legend | awk '{
    if ($3 == "active") { status="● Active" }
    else if ($3 == "failed") { status="❌ Failed" }
    else { status="○ Inactive" }
    print $1 " | " status
}' | sort)

# 3. Launch Rofi
SEL_LINE=$(echo -e "$MENU_LIST" | rofi -dmenu -i \
    -theme ~/.config/rofi/walker.rasi \
    -theme-str 'window { width: 600px; }' \
    -theme-str 'listview { lines: 10; }' \
    -theme-str 'entry { placeholder: "Manage Services..."; }' \
    -p "Services")

# 4. Extract Service Name (Grab the first word before the ' | ')
SEL_SERVICE=$(echo "$SEL_LINE" | awk '{print $1}')

if [[ -n "$SEL_SERVICE" ]]; then
    # 5. Toggle Logic
    if systemctl is-active --quiet "$SEL_SERVICE"; then
        notify-send -a "Service Manager" "Attempting to stop $SEL_SERVICE"
        # Using kitty for the sudo prompt ensures no focus-lock issues
        kitty --class floating-terminal --title "Service Auth" sh -c "sudo systemctl stop $SEL_SERVICE" &
    else
        notify-send -a "Service Manager" "Attempting to start $SEL_SERVICE"
        kitty --class floating-terminal --title "Service Auth" sh -c "sudo systemctl start $SEL_SERVICE" &
    fi
    
    # 6. Re-open the menu (Now 100% Safe!)
    # Because we removed the 'cp' disk-write at the top, un-commenting 
    # 'exec "$0"' is safe and provides an updated status list.
    sleep 0.5
    exec "$0"
fi

disown
exit 0