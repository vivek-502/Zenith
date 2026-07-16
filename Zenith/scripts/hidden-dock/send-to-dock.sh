#!/usr/bin/env bash

SPECIAL="magic"
CACHE_DIR="$HOME/.config/Zenith/.cache/dock-cache"

mkdir -p "$CACHE_DIR"

# Get active window address (remains the same)
WINDOW_ADDR=$(hyprctl activewindow -j | jq -r '.address')

# Screenshot the window
hyprshot -m window -m active \
    -o "$CACHE_DIR" \
    -f "${WINDOW_ADDR}.png" \
    -s

# Use hyprctl eval to execute the same Lua logic that works in your bind
hyprctl eval "hl.dispatch(hl.dsp.window.move({ workspace = 'special:$SPECIAL', follow = false }))"