#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

# cleanups
# pkill nautilus 2>/dev/null || true
killall mpvpaper 2>/dev/null || true
killall gnome-clocks 2>/dev/null || true


"$SCRIPT_DIR/wal-gtk.sh"
"$SCRIPT_DIR/wal-kitty.sh"
"$SCRIPT_DIR/wal-waybar.sh"
waybar &
"$SCRIPT_DIR/wal-rofi.sh"
"$SCRIPT_DIR/wal-hypr.sh"
"$SCRIPT_DIR/wal-icon-theme.sh"
"$SCRIPT_DIR/wal-sway.sh"

gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'


killall swaync && swaync &
sleep 1
notify-send "theme applied"
