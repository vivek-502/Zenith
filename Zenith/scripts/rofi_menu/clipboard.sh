#!/bin/bash

# 1. RAM Injection
# Start the selector instantly. No disk-write here, because we're about 
# to do heavy IO operations below.
hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

cliphist list | \
        rofi -dmenu --config -config ~/.config/rofi/walker.rasi \
        -theme-str 'inputbar { children: [ "entry" ]; }' \
        -theme-str 'listview { lines: 7; }' \
        -theme-str 'window { width: 50%; }' \
        -theme-str 'entry { placeholder: "Type to search..."; }' | cliphist decode | wl-copy 
