#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

# --- ensure safe defaults if env.sh doesn't define them ---
if ! declare -p STATE_FILE >/dev/null 2>&1; then
  STATE_FILE="$HOME/.config/Zenith/.last_swww_wallpaper"
fi

if ! declare -p ICON_DIRS >/dev/null 2>&1; then
  ICON_DIRS=( "$HOME/.local/share/icons" "/usr/share/icons" "$HOME/.icons" )
fi

if [ ! -f "$WAL_JSON" ]; then
  notify-send "Icon auto-select" "pywal colors.json not found at $WAL_JSON"
  echo "ERROR: $WAL_JSON not found" >&2
  exit 1
fi

# ---------------- get current wallpaper basename (if available) ----------------
WALLPAPER=""
if [ -n "${1:-}" ]; then
  WALLPAPER="$1"
elif [ -f "$STATE_FILE" ]; then
  WALLPAPER="$(<"$STATE_FILE")"
fi

BASENAME="$(basename "${WALLPAPER:-}")"

# ---------------- special -i[...] override check ----------------
# look for -i[SomeName] anywhere in the filename
REQUESTED_ICON=""
if [[ "$BASENAME" =~ -i\[([^]]+)\] ]]; then
  REQUESTED_ICON="${BASH_REMATCH[1]}"
  # trim whitespace
  REQUESTED_ICON="${REQUESTED_ICON#"${REQUESTED_ICON%%[![:space:]]*}"}"
  REQUESTED_ICON="${REQUESTED_ICON%"${REQUESTED_ICON##*[![:space:]]}"}"
fi

if [ -n "$REQUESTED_ICON" ]; then
  # search icon dirs for case-insensitive exact match
  FOUND_PATH=""
  while IFS= read -r -d $'\0' candidate; do
    # candidate is the directory path
    name="$(basename "$candidate")"
    if [[ "${name,,}" == "${REQUESTED_ICON,,}" ]]; then
      FOUND_PATH="$candidate"
      break
    fi
  done < <(find "${ICON_DIRS[@]}" -maxdepth 2 -mindepth 1 -type d -print0 2>/dev/null)

  if [ -n "$FOUND_PATH" ]; then
    # Apply immediately
    if command -v gsettings >/dev/null 2>&1; then
      gsettings set org.gnome.desktop.interface icon-theme "$REQUESTED_ICON" 2>/dev/null || true
    fi
    if command -v gtk-update-icon-cache >/dev/null 2>&1; then
      gtk-update-icon-cache -f -t "$FOUND_PATH" >/dev/null 2>&1 || true
    fi
    notify-send "Icon auto-applied (override)" "$REQUESTED_ICON — applied from wallpaper tag"
    echo "Applied requested icon theme: $REQUESTED_ICON (path: $FOUND_PATH)" >&2
    exit 0
  else
    notify-send "Icon auto-select" "Requested icon theme '$REQUESTED_ICON' not found; continuing auto-select"
    echo "Requested icon theme '$REQUESTED_ICON' not found, falling back to automatic selection." >&2
    # continue to automatic selection
  fi
fi

# ---------------- helpers: hex -> rgb, rgb -> hue, hue -> family ----------------
hex_to_rgb() {
  local h="${1#\#}"
  if [ ${#h} -eq 3 ]; then
    h="${h:0:1}${h:0:1}${h:1:1}${h:1:1}${h:2:1}${h:2:1}"
  fi
  printf "%d %d %d" "$((16#${h:0:2}))" "$((16#${h:2:2}))" "$((16#${h:4:2}))"
}

rgb_to_hue() {
  # args: R G B
  awk -v r="$1" -v g="$2" -v b="$3" '
  BEGIN{
    r/=255; g/=255; b/=255
    max=r; if(g>max) max=g; if(b>max) max=b
    min=r; if(g<min) min=g; if(b<min) min=b
    d=max-min
    if(d==0){h=0}
    else if(max==r){ h=60 * ( ( (g-b)/d ) % 6 ) }
    else if(max==g){ h=60 * ( ( (b-r)/d ) + 2 ) }
    else { h=60 * ( ( (r-g)/d ) + 4 ) }
    if(h<0) h+=360
    printf("%d\n", int(h+0.5))
  }'
}

hue_to_family() {
  local h=$1
  if (( h < 20 || h >= 340 )); then echo "red"
  elif (( h < 45 )); then echo "orange"
  elif (( h < 70 )); then echo "yellow"
  elif (( h < 160 )); then echo "green"
  elif (( h < 200 )); then echo "cyan"
  elif (( h < 260 )); then echo "blue"
  elif (( h < 320 )); then echo "purple"
  else echo "neutral"
  fi
}

# infer theme color from name
theme_color_from_name() {
  local name="${1,,}"  # lowercase
  if [[ $name =~ red ]]; then echo "red" && return; fi
  if [[ $name =~ orange ]]; then echo "orange" && return; fi
  if [[ $name =~ yellow ]]; then echo "yellow" && return; fi
  if [[ $name =~ green ]]; then echo "green" && return; fi
  if [[ $name =~ cyan|teal ]]; then echo "cyan" && return; fi
  if [[ $name =~ blue ]]; then echo "blue" && return; fi
  if [[ $name =~ purple|violet|magenta ]]; then echo "purple" && return; fi
  if [[ $name =~ dark|black|mono|papirus|numix ]]; then echo "mono" && return; fi
  if [[ $name =~ light|white|sur ]]; then echo "light" && return; fi
  if [[ $name =~ yaru-([a-z]+) ]]; then
    echo "${BASH_REMATCH[1]}"
    return
  fi
  echo "neutral"
}

# ---------------- get accent color and compute hue/family ----------------
ACCENT_HEX=$(jq -r '.colors.color4 // .colors.color2 // .colors.color0 // .special.background' "$WAL_JSON")
if [ -z "$ACCENT_HEX" ] || [ "$ACCENT_HEX" = "null" ]; then
  ACCENT_HEX=$(jq -r '.special.background' "$WAL_JSON")
fi
if [ -z "$ACCENT_HEX" ] || [ "$ACCENT_HEX" = "null" ]; then
  notify-send "Icon auto-select" "No accent color found in wal json"
  exit 1
fi

# ensure leading '#'
if [[ "$ACCENT_HEX" != \#* ]]; then
  ACCENT_HEX="#$ACCENT_HEX"
fi

read R G B <<< "$(hex_to_rgb "$ACCENT_HEX")"
HUE=$(rgb_to_hue "$R" "$G" "$B")
WALL_FAMILY=$(hue_to_family "$HUE")

# debug output
echo "Accent: $ACCENT_HEX -> $R,$G,$B Hue:$HUE Family:$WALL_FAMILY" >&2

# ---------------- build list of theme directories ----------------
THEME_PATHS=()
for d in "${ICON_DIRS[@]}"; do
  if [ -d "$d" ]; then
    while IFS= read -r -d $'\0' p; do
      THEME_PATHS+=("$p")
    done < <(find "$d" -maxdepth 2 -mindepth 1 -type d -print0 2>/dev/null)
  fi
done

if [ ${#THEME_PATHS[@]} -eq 0 ]; then
  notify-send "Icon auto-select" "No icon themes found in ${ICON_DIRS[*]}"
  exit 0
fi

BEST_THEME=""
BEST_PATH=""
BEST_SCORE=-999

# ---------------- scoring loop ----------------
for themepath in "${THEME_PATHS[@]}"; do
  # skip directories without index.theme
  if [ ! -f "$themepath/index.theme" ]; then
    continue
  fi
  theme=$(basename "$themepath")
  tcolor=$(theme_color_from_name "$theme")
  score=0

  # exact family match
  if [ "$tcolor" = "$WALL_FAMILY" ]; then
    score=$((score + 8))
  fi

  # compatible near-matches
  if [ "$WALL_FAMILY" = "blue" ] && [ "$tcolor" = "cyan" ]; then score=$((score + 5)); fi
  if [ "$WALL_FAMILY" = "purple" ] && ([[ "$tcolor" = "magenta" ]] || [[ "$tcolor" = "red" ]]); then score=$((score + 4)); fi
  if [ "$WALL_FAMILY" = "green" ] && [ "$tcolor" = "cyan" ]; then score=$((score + 4)); fi

  # neutral / mono base
  if [ "$tcolor" = "neutral" ]; then score=$((score + 3)); fi
  if [ "$tcolor" = "mono" ]; then score=$((score + 2)); fi

  # prefer named variants (contains '-' or color word)
  if [[ "$theme" =~ - ]]; then score=$((score + 1)); fi
  if [[ "${theme,,}" =~ $WALL_FAMILY ]]; then score=$((score + 2)); fi

  # bonus for larger themes (more files)
  cnt=$(find "$themepath" -maxdepth 3 -type f 2>/dev/null | wc -l)
  if [ "$cnt" -gt 50 ]; then score=$((score + 1)); fi
  if [ "$cnt" -gt 200 ]; then score=$((score + 1)); fi

  # small penalty for themes named 'hicolor' (fallback)
  if [[ "${theme,,}" =~ hicolor ]]; then score=$((score - 2)); fi

  if (( score > BEST_SCORE )); then
    BEST_SCORE=$score
    BEST_THEME="$theme"
    BEST_PATH="$themepath"
  fi
done

# ---------------- apply best theme ----------------
if [ -n "$BEST_THEME" ]; then
  echo "Chosen icon theme: $BEST_THEME (score $BEST_SCORE) path:$BEST_PATH" >&2

  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface icon-theme "$BEST_THEME" 2>/dev/null || true
  else
    echo "gsettings not available; cannot set icon theme automatically" >&2
  fi

  # update icon cache if available (best-effort)
  if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d "$BEST_PATH" ]; then
    gtk-update-icon-cache -f -t "$BEST_PATH" >/dev/null 2>&1 || true
  fi

  # notify-send "Icon theme auto-applied" "$BEST_THEME\nHue: $WALL_FAMILY"
else
  notify-send "Icon auto-select" "No suitable icon theme found"
fi

exit 0
