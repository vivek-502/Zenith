#!/usr/bin/env bash

# 1. RAM Injection
# Launch the selector instantly. We skip the 'cp' and 'sleep' to 
# give the CPU more cycles for ImageMagick and swww.
hyprctl eval "dofile('$HOME/.config/rofi/animations/Theme_selector_anim.lua')"

# ---- Paths ----
WALL_DIR="$HOME/.config/Zenith/live-backgrounds"
ROFI_THEME="$HOME/.config/rofi/theme-switcher.rasi"
CACHE_DIR="$HOME/.cache/live_wallpaper_thumbs"

mkdir -p "$CACHE_DIR"

# Ensure swww daemon is running silently
pgrep -x "awww-daemon" > /dev/null || awww-daemon & 

# ---- Generate Wallpaper List with Cached Previews ----
entries=""
# Optimized loop to reduce subshell overhead
while IFS=$'\t' read -r filename fullpath; do
    thumb_name=$(echo -n "$fullpath" | md5sum | cut -d' ' -f1)
    thumb_path="$CACHE_DIR/${thumb_name}.jpg"

    # Create thumbnail only if missing
    if [[ ! -f "$thumb_path" ]]; then
        # MAGIC FIX: ${fullpath}[0] tells ImageMagick to only grab the FIRST frame
        magick "${fullpath}[0]" -resize 1920x1080^ -gravity center -extent 1920x1080 "$thumb_path"
    fi

    # Formatting for Rofi: Icon + Path Info
    entries+="$filename\0icon\x1f$thumb_path\x1finfo\x1f$fullpath\n"

done < <(find "$WALL_DIR" -type f -iregex '.*\.\(gif\)' -printf "%f\t%p\n" | sort -f)

# ---- Show Rofi Menu ----
SELECTED_INDEX=$(printf "%b" "$entries" | rofi -dmenu -i -show-icons \
    -theme "$ROFI_THEME" -format "i" -p "Select Wallpaper")

# Handle exits
[[ -z "$SELECTED_INDEX" ]] && exit 0
pkill rofi

# Extract ORIGINAL path using the index (offset by 1 for sed)
FULL_PATH=$(printf "%b" "$entries" | sed -n "$((SELECTED_INDEX + 1))p" | awk -F'\x1finfo\x1f' '{print $2}')

if [[ -f "$FULL_PATH" ]]; then
    
    # ---- RANDOMIZATION LOGIC ----
    TYPES=("outer" "wipe" "grow")
    RAND_TYPE=${TYPES[$RANDOM % ${#TYPES[@]}]}
    RAND_X=$(awk -v seed=$(date +%N) 'BEGIN{srand(seed); print rand()}')
    RAND_Y=$(awk -v seed=$(date +%N%f) 'BEGIN{srand(seed); print rand()}')
    
    # ---- APPLY WALLPAPER ----
    killall mpvpaper 2>/dev/null || true

    # swww runs in background to prevent script hang
    awww img "$FULL_PATH"

    # ---- System Updates (Backgrounded for Speed) ----
    (
        # Also extracting only the first frame [0] for your system JPEGs
        # to prevent background CPU hanging!
        magick "${FULL_PATH}[0]" "$HOME/.config/Zenith/current/background.jpeg"
        magick "${FULL_PATH}[0]" -resize 530x990^ -gravity center -extent 530x990 "$HOME/.config/Zenith/current/rofi-vertical.jpeg"
        magick "${FULL_PATH}[0]" -resize 930x530^ -gravity center -extent 930x530 "$HOME/.config/Zenith/current/rofi-horizontal.jpeg"
        notify-send -a "Appearance" "Wallpaper Applied" "$(basename "$FULL_PATH")"
    ) &

else
    notify-send -a "System" "Error" "File not found: $FULL_PATH"
fi

disown
exit 0
