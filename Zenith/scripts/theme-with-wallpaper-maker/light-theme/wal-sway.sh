#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

[[ -f "$WAL_JSON" ]] || {
  echo "❌ pywal colors not found: $WAL_JSON" >&2
  exit 1
}


#__________________________________ swaync and swayosd _____________________________

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


# ---------------- extract colors ----------------
BG=$(jq -r '.special.background' "$WAL_JSON")
FG=$(jq -r '.special.foreground' "$WAL_JSON")

COLOR0=$(jq -r '.colors.color0' "$WAL_JSON")
COLOR1=$(jq -r '.colors.color1' "$WAL_JSON")
COLOR2=$(jq -r '.colors.color2' "$WAL_JSON")
COLOR4=$(jq -r '.colors.color4' "$WAL_JSON")
COLOR8=$(jq -r '.colors.color8' "$WAL_JSON")
COLOR14=$(jq -r '.colors.color14' "$WAL_JSON")

FINAL_BG=$(hex_rgba "$BG" $SWAY_BG_OP)


# ---------------- rewrite swaync.css ----------------
echo "
/* ---------------- Colors ---------------- */
@define-color background      $FINAL_BG;
@define-color background-alt  $FINAL_BG;
@define-color text            $FG;
@define-color text-alt        $COLOR8;
@define-color selected        alpha(@text-alt, .35);
@define-color hover           alpha(@text-alt, .25);
@define-color urgent          $COLOR14;
" | cat > "$THEME_DIR/swaync.css"

# ---------------- restart services (AFTER files) ----------------
pkill swayosd-server 2>/dev/null || true
pkill swaync 2>/dev/null || true
sleep 0.5

swayosd-server --style ~/.config/swayosd/style.css >/dev/null 2>&1 &
disown

swaync >/dev/null 2>&1 &
disown

sleep 0.3
wallpaper=$(cat "$HOME/.config/Zenith/.last_swww_wallpaper")
filename=$(basename "$wallpaper")

notify-send "theme applied" "$filename"
