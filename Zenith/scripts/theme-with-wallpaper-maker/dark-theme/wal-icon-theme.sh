#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh" 2>/dev/null || true

STATE_FILE="${STATE_FILE:-$HOME/.config/Zenith/.last_swww_wallpaper}"
WAL_JSON="${WAL_JSON:-$HOME/.cache/wal/colors.json}"
ICON_DIRS=( "$HOME/.local/share/icons" "/usr/share/icons" "$HOME/.icons" )

if [ ! -f "$WAL_JSON" ]; then
  notify-send "Icon auto-select" "colors.json not found!"
  exit 1
fi

WALLPAPER="${1:-$(cat "$STATE_FILE" 2>/dev/null || echo "")}"
BASENAME="$(basename "$WALLPAPER")"

# ---------------- 1. Override Check ----------------
if [[ "$BASENAME" =~ -i\[([^]]+)\] ]]; then
  REQUESTED_ICON="${BASH_REMATCH[1]}"
  REQUESTED_ICON="${REQUESTED_ICON#"${REQUESTED_ICON%%[![:space:]]*}"}"
  REQUESTED_ICON="${REQUESTED_ICON%"${REQUESTED_ICON##*[![:space:]]}"}"
  
  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface icon-theme "$REQUESTED_ICON"
    notify-send "Icon Override" "Applied: $REQUESTED_ICON"
    exit 0
  fi
fi

# ---------------- 2. Smart Color & Brightness Extraction ----------------
# We extract the Background to determine Dark/Light mode, and color4/color2 for the Accent Hue
BG_HEX=$(jq -r '.special.background' "$WAL_JSON")
ACCENT_HEX=$(jq -r '.colors.color4 // .colors.color2 // .colors.color1' "$WAL_JSON")

# AWK script to calculate both Hue and Background Luminance in one lightning-fast pass
read HUE WALL_FAMILY MODE <<< $(awk -v bg="$BG_HEX" -v acc="$ACCENT_HEX" '
  function hex2rgb(h,   r,g,b) {
    gsub("#", "", h);
    if(length(h)==3) h=substr(h,1,1) substr(h,1,1) substr(h,2,1) substr(h,2,1) substr(h,3,1) substr(h,3,1);
    r=strtonum("0x" substr(h,1,2)); g=strtonum("0x" substr(h,3,2)); b=strtonum("0x" substr(h,5,2));
    return r " " g " " b;
  }
  BEGIN {
    # Determine Mode (Dark/Light) from Background
    split(hex2rgb(bg), bg_rgb, " ");
    lum = 0.299*bg_rgb[1] + 0.587*bg_rgb[2] + 0.114*bg_rgb[3];
    mode = (lum < 128) ? "dark" : "light";

    # Determine Hue from Accent
    split(hex2rgb(acc), rgb, " ");
    r=rgb[1]/255; g=rgb[2]/255; b=rgb[3]/255;
    max=r; if(g>max) max=g; if(b>max) max=b;
    min=r; if(g<min) min=g; if(b<min) min=b;
    d=max-min; h=0;
    if(d!=0){
      if(max==r) h=60*(((g-b)/d)%6);
      else if(max==g) h=60*(((b-r)/d)+2);
      else h=60*(((r-g)/d)+4);
    }
    if(h<0) h+=360;
    
    # Map to Family
    fam="neutral";
    if(h<20 || h>=340) fam="red"; else if(h<45) fam="orange"; else if(h<70) fam="yellow";
    else if(h<160) fam="green"; else if(h<200) fam="cyan"; else if(h<260) fam="blue"; else if(h<320) fam="purple";
    
    print int(h) " " fam " " mode;
  }
')

echo "Target: $WALL_FAMILY ($MODE mode)" >&2

# ---------------- 3. High-Speed Scoring ----------------
BEST_THEME=""
BEST_SCORE=-999

# Combine all valid icon theme directories into a list instantly
while IFS= read -r -d $'\0' themepath; do
  theme=$(basename "$themepath")
  tname="${theme,,}"
  score=0

  # Skip fallbacks
  if [[ "$tname" =~ hicolor|default|breeze-dark ]]; then continue; fi

  # 1. Evaluate Color Match
  if [[ "$tname" =~ $WALL_FAMILY ]]; then
    score=$((score + 20)) # Exact color word in name (e.g., Tela-Blue)
  elif [[ "$WALL_FAMILY" == "blue" && "$tname" =~ cyan|ocean ]]; then score=$((score + 10))
  elif [[ "$WALL_FAMILY" == "purple" && "$tname" =~ magenta|pink ]]; then score=$((score + 10))
  elif [[ "$WALL_FAMILY" == "green" && "$tname" =~ teal|mint ]]; then score=$((score + 10))
  elif [[ "$tname" =~ mono|standard|nord|dracula ]]; then score=$((score + 5)) # Good fallbacks
  fi

  # 2. Evaluate Light/Dark Variant Appropriateness
  if [[ "$MODE" == "dark" ]]; then
    if [[ "$tname" =~ dark ]]; then score=$((score + 15)); fi
    if [[ "$tname" =~ light ]]; then score=$((score - 20)); fi # Penalize bright icons on dark theme
  else
    if [[ "$tname" =~ light ]]; then score=$((score + 15)); fi
    if [[ "$tname" =~ dark ]]; then score=$((score - 20)); fi # Penalize dark icons on bright theme
  fi

  if (( score > BEST_SCORE )); then
    BEST_SCORE=$score
    BEST_THEME="$theme"
  fi
done < <(find "${ICON_DIRS[@]}" -maxdepth 2 -name "index.theme" -printf "%h\0" 2>/dev/null)

# ---------------- 4. Apply Best Theme ----------------
if [ -n "$BEST_THEME" ]; then
  echo "Chosen: $BEST_THEME (Score: $BEST_SCORE)" >&2

  # 1. Apply via gsettings (Live update for many apps)
  if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.interface icon-theme "$BEST_THEME"
  fi

  # 2. Apply via GTK-3.0 config (Crucial for Hyprland native GTK apps)
  GTK3_CONF="$HOME/.config/gtk-3.0/settings.ini"
  if [ -f "$GTK3_CONF" ]; then
    sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$BEST_THEME/" "$GTK3_CONF"
  fi

  # notify-send -a "Theme Engine" "Icons Updated" "$BEST_THEME\nStyle: $WALL_FAMILY ($MODE)"
else
  notify-send "Icon Engine" "No suitable icons found."
fi

exit 0
