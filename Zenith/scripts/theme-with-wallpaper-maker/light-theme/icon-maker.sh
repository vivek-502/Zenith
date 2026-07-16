#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

[[ -f "$WAL_JSON" ]] || {
  echo "❌ pywal colors not found: $WAL_JSON" >&2
  exit 1
}

# ---------------- extract colors ----------------
BG=$(jq -r '.special.background' "$WAL_JSON")
FG=$(jq -r '.special.foreground' "$WAL_JSON")

COLOR0=$(jq -r '.colors.color0' "$WAL_JSON")
COLOR1=$(jq -r '.colors.color1' "$WAL_JSON")
COLOR3=$(jq -r '.colors.color3' "$WAL_JSON")
COLOR4=$(jq -r '.colors.color4' "$WAL_JSON")
COLOR8=$(jq -r '.colors.color8' "$WAL_JSON")

# Function to convert hex color to hue in degrees
get_hue_from_hex() {
    local hex_color=$1

    # Remove the '#' if present
    hex_color="${hex_color#'#'}"

    # Convert hex to RGB
    local r=$((16#${hex_color:0:2}))
    local g=$((16#${hex_color:2:2}))
    local b=$((16#${hex_color:4:2}))

    # Calculate max and min RGB values
    local max=$((r > g ? (r > b ? r : b) : (g > b ? g : b)))
    local min=$((r < g ? (r < b ? r : b) : (g < b ? g : b)))
    
    # Initialize hue
    local hue=0

    # Calculate hue
    if ((max == min)); then
        hue=0  # Undefined hue
    elif ((max == r)); then
        hue=$(( (60 * (g - b) / (max - min) + 360) % 360 ))
    elif ((max == g)); then
        hue=$(( (60 * (b - r) / (max - min) + 120) % 360 ))
    else
        hue=$(( (60 * (r - g) / (max - min) + 240) % 360 ))
    fi

    echo "$hue"
}

hue_value_degree=$(get_hue_from_hex "$COLOR1")
hue_percentage=$(echo "$hue_value_degree / 360 * 100" | bc -l) 

# Check if directory path is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

DIRECTORY_PATH="$1"

# Check if the provided argument is a valid directory
if [ ! -d "$DIRECTORY_PATH" ]; then
    echo "Error: $DIRECTORY_PATH is not a valid directory."
    exit 1
fi


# Find and echo the full paths of .png and .jpg files
find "$DIRECTORY_PATH" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.svg" \) | while read -r file
do
    # Separate filename and directory path
    FILENAME=$(basename "$file")
    FILEDIR=$(dirname "$file")

    # Print the full path, filename, and directory
    echo "Working on: $file"
    # magick "$file" -colorspace gray -fill "$COLOR1" -tint 100% "$file"   
    magick "$file" -colorspace HSL -channel Red -evaluate set $hue_percentage% +channel -colorspace sRGB "$file"   

    sleep 0.01
done

notify-send "Completed....."
echo "Completed...."
echo "Hue percentage for $COLOR1 $hue_percentage%"