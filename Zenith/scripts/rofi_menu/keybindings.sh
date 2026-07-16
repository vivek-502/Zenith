#!/bin/bash

# Path to your keybinds manual
KEYBINDS_FILE="$HOME/.config/Zenith/docs/keybindings_list.txt"

# 1. RAM Injection
# Start the selector instantly. No disk-write here, because we're about 
# to do heavy IO operations below.
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# Check if file exists
if [ ! -f "$KEYBINDS_FILE" ]; then
    echo "Keybinds file not found!"
    exit 1
fi

# Feed the file content to Rofi
cat "$KEYBINDS_FILE" | rofi -dmenu -i -p "󰌌 Keybinds" -config ~/.config/rofi/walker.rasi \
    -theme-str 'window { width: 600px; } 
        listview { lines: 8; scrollbar: true; }
        scrollbar {
            width:                        6px;          /* Width of the scrollbar */
            handle-width:                 6px;          /* Width of the moving handle */
            handle-color:                 @selected-normal-background; /* Color of the handle */
            background-color:             @input-background;           /* Color of the track */
            
            /* Aesthetics */
            border-radius:                10px;         /* Rounded scrollbar */
            margin:                       0px 0px 0px 5px; /* Adds space between list and bar */
        }
    '
