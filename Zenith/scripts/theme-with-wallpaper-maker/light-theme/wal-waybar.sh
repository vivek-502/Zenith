#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

[[ -f "$WAL_JSON" ]] || {
  echo "❌ pywal colors not found: $WAL_JSON" >&2
  exit 1
}


#_________________________________ waybar _________________________________________

# ---------------- extract colors ----------------
BG=$(jq -r '.special.background' "$WAL_JSON")
FG=$(jq -r '.special.foreground' "$WAL_JSON")
COLOR1=$(jq -r '.colors.color1' "$WAL_JSON")
COLOR2=$(jq -r '.colors.color2' "$WAL_JSON")
COLOR3=$(jq -r '.colors.color3' "$WAL_JSON")
COLOR4=$(jq -r '.colors.color4' "$WAL_JSON")
COLOR5=$(jq -r '.colors.color5' "$WAL_JSON")
COLOR6=$(jq -r '.colors.color6' "$WAL_JSON")
COLOR7=$(jq -r '.colors.color7' "$WAL_JSON")
COLOR8=$(jq -r '.colors.color8' "$WAL_JSON")
COLOR9=$(jq -r '.colors.color9' "$WAL_JSON")
COLOR10=$(jq -r '.colors.color10' "$WAL_JSON")
COLOR11=$(jq -r '.colors.color11' "$WAL_JSON")
COLOR12=$(jq -r '.colors.color12' "$WAL_JSON")

# ---------------- hex → rgba helper ----------------
hex_to_rgba() {
  local h="${1#\#}"
  local a="${2:-0.55}"
  printf "rgba(%d, %d, %d, %s)" \
    $((16#${h:0:2})) \
    $((16#${h:2:2})) \
    $((16#${h:4:2})) \
    "$a"
}

BG_RGBA_50=$(hex_to_rgba "$BG" 0.5)
FINAL_BG=$(hex_to_rgba "$BG" $WAYBAR_BG_OP)

# ---------------- FULL FILE REWRITE ----------------
echo "
@define-color background $FINAL_BG;

@define-color foreground $FG;

@define-color selected $COLOR1;

@define-color color-2 $COLOR2;
@define-color color-3 $COLOR3;
@define-color color-4 $COLOR4;
@define-color color-5 $COLOR5;
@define-color color-6 $COLOR6;
@define-color color-7 $COLOR7;
@define-color color-8 $COLOR8;
@define-color color-9 $COLOR9;
@define-color color-10 $COLOR10;
@define-color color-11 $COLOR11;
@define-color color-12 $COLOR12;

@define-color secondary_background $BG_RGBA_50;
@define-color overlay_background rgba(1, 1, 1, 0.1);
" | cat > "$THEME_DIR/waybar.css"

pkill waybar