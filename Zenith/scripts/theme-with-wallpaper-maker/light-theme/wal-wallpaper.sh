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
wal -i "$WALLPAPER" -l -n
sleep 0.3


# chnage the background saturation --------------------------------------------------------------

if [[ ! -f "$WAL_JSON" ]]; then
    echo "Error: $WAL_JSON not found."
    exit 1
fi

# We use Python to calculate the average saturation of the palette
NEW_HEX=$(python3 -c "
import json
import colorsys
import os

def get_hsv(hex_str):
    hex_str = hex_str.lstrip('#')
    r, g, b = [int(hex_str[i:i+2], 16) / 255.0 for i in (0, 2, 4)]
    return colorsys.rgb_to_hsv(r, g, b)

with open(os.path.expanduser('$WAL_JSON'), 'r') as f:
    data = json.load(f)

# 1. Analyze the palette saturation
colors_list = data['colors'].values()
saturations = [get_hsv(c)[1] for c in colors_list]
avg_saturation = sum(saturations) / len(saturations)

# Threshold: If avg saturation is < 12%, consider it monochrome
IS_MONOCHROME = avg_saturation < 0.12

# 2. Get original background info
bg_hex = data['special']['background']
h, s, v = get_hsv(bg_hex)

if IS_MONOCHROME:
    # Grayscale logic: Pure gray, no tint
    # H=0, S=0, V=0.80 (Light gray)
    new_h, new_s, new_v = 0.0, 0.00, 0.80
else:
    # Colorful logic: Keep wallpaper tint
    # H=original, S=10%, V=90%
    new_h, new_s, new_v = h, 0.10, 0.90

# 3. Convert back to Hex
nr, ng, nb = colorsys.hsv_to_rgb(new_h, new_s, new_v)
print('#{:02x}{:02x}{:02x}'.format(int(round(nr*255)), int(round(ng*255)), int(round(nb*255))))
")

# Update the file
jq --arg new_bg "$NEW_HEX" '.special.background = $new_bg' "$WAL_JSON" > "$WAL_JSON.tmp" && mv "$WAL_JSON.tmp" "$WAL_JSON"

echo "Analysis complete. Palette avg saturation was low? Update: $NEW_HEX"
