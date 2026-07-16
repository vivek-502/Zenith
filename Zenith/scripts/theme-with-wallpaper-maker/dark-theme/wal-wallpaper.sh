#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

# ---- Cache Setup ----
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"
mkdir -p "$THUMB_DIR"

# ---------- rofi wallpaper picker ----------
entries=""
shopt -s nullglob

# Loop through wallpapers and generate/load high-res thumbnails
for img in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
  name=$(basename "$img")
  
  # Create a unique thumb name based on the file path to prevent collisions
  thumb_hash=$(echo "$img" | md5sum | cut -d' ' -f1)
  thumb="$THUMB_DIR/${thumb_hash}.jpg"

  # Generate High-Quality 1920x1080 thumbnail if it doesn't exist
  if [ ! -f "$thumb" ]; then
    magick "$img" -filter Lanczos -resize 1920x1080^ -gravity center -extent 1920x1080 -quality 100 "$thumb"
  fi

  # Pass the thumbnail to Rofi for the preview icon
  entries+="$name\0icon\x1f$thumb\n"
done
shopt -u nullglob

SELECTED=$(printf "%b" "$entries" | rofi -dmenu -i -show-icons -theme "$ROFI_THEME" -p "Wallpaper")

# Exit with 1 (error) so parent scripts know we cancelled
[ -z "$SELECTED" ] && exit 1

WALLPAPER="$WALL_DIR/$SELECTED"
echo "$WALLPAPER" > "$STATE_FILE"

# APPLY the wallpaper -----------------------------

# ---- ULTRA-RANDOMIZATION LOGIC ----
TYPES=("outer" "wipe" "grow")
RAND_TYPE=${TYPES[$RANDOM % ${#TYPES[@]}]}

RAND_X=$(awk -v seed=$(date +%N) 'BEGIN{srand(seed); print rand()}')
RAND_Y=$(awk -v seed=$(date +%N%f) 'BEGIN{srand(seed); print rand()}')

RAND_ANGLE=$(( RANDOM % 360 ))
RAND_STEP=$(( 60 + RANDOM % 61 ))

# Kill competing background processes
killall mpvpaper 2>/dev/null || true

# ---- APPLY WALLPAPER ----
awww img "$WALLPAPER" \
    --transition-type "$RAND_TYPE" \
    --transition-pos "$RAND_X,$RAND_Y" \
    --transition-angle "$RAND_ANGLE" \
    --transition-step "$RAND_STEP" \
    --transition-fps 60

# ---------- generate images ----------
cp "$WALLPAPER" "$CURRENT_DIR/background.jpeg"

# Using Lanczos filter for the system UI images as well
magick "$WALLPAPER" -filter Lanczos -resize 530x990^ -gravity center -extent 530x990 \
  "$CURRENT_DIR/rofi-vertical.jpeg"

magick "$WALLPAPER" -filter Lanczos -resize 930x530^ -gravity center -extent 930x530 \
  "$CURRENT_DIR/rofi-horizontal.jpeg"

# ---------- generate palette ----------
wal -i "$WALLPAPER" -n
sleep 0.3
