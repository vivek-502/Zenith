#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

[[ -f "$WAL_JSON" ]] || {
  echo "❌ pywal colors not found: $WAL_JSON" >&2
  exit 1
}


#______________________________ rofi theme apply __________________________________________



# ---------------- extract colors ----------------
BG=$(jq -r '.special.background' "$WAL_JSON")
FG=$(jq -r '.special.foreground' "$WAL_JSON")

COLOR0=$(jq -r '.colors.color0' "$WAL_JSON")
COLOR1=$(jq -r '.colors.color1' "$WAL_JSON")
COLOR2=$(jq -r '.colors.color2' "$WAL_JSON")
COLOR8=$(jq -r '.colors.color8' "$WAL_JSON")

# ---------------- hex → rgba (percent alpha) ----------------
hex_rgba() {
  local h="${1#\#}"
  local a="${2:-1}"
  printf "rgba(%d, %d, %d, %s)" \
    $((16#${h:0:2})) \
    $((16#${h:2:2})) \
    $((16#${h:4:2})) \
    "$a"
}


BG_100=$(hex_rgba "$BG" $ROFI_BG_OP)
BG_0=$(hex_rgba "$BG" 0)
FG_100=$(hex_rgba "$FG" 1)

BORDER_100=$(hex_rgba "$COLOR8" 1)
SEPARATOR_10=$(hex_rgba "$COLOR8" 0.1)

SELECT_BG_100=$(hex_rgba "$COLOR2" 1)
INPUT_BG_10=$(hex_rgba "$COLOR2" 0.1)

# ---------------- FULL FILE REWRITE ----------------
echo "
/* ---------- GLOBAL ---------- */
* {
    background:                  $BG_100;
    background-color:            $BG_0;

    foreground:                  $FG_100;
    normal-foreground:           @foreground;
    alternate-normal-foreground: @foreground;

    bordercolor:                 $BORDER_100;
    border-color:                @bordercolor;
    separatorcolor:              $SEPARATOR_10;

    selected-normal-background:  $SELECT_BG_100;
    selected-normal-foreground:  $FG_100;

    active-foreground:           $FG_100;

    normal-background:           $BG_0;
    alternate-normal-background: $BG_0;
    input-background:            $INPUT_BG_10;     
    spacing: 6;
}
" | cat > "$THEME_DIR/config.rasi"
