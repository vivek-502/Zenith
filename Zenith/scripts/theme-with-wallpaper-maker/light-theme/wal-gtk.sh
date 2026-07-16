#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

[[ -f "$WAL_JSON" ]] || {
  echo "❌ pywal colors not found: $WAL_JSON" >&2
  exit 1
}


# _________________________________________ GTK ______________________________________


# -------- sanity check --------
if [ ! -f "$WAL_JSON" ]; then
  echo "❌ colors.json not found at $WAL_JSON"
  exit 1
fi

# -------- extract colors (NO GUESSING) --------
BG=$(jq -r '.special.background' "$WAL_JSON")
FG=$(jq -r '.special.foreground' "$WAL_JSON")
ACCENT=$(jq -r '.colors.color4' "$WAL_JSON")

# -------- hex → rgba helper --------
hex_to_rgba() {
  local h="${1#\#}"
  local a="${2:-0.9}"
  printf "rgba(%d,%d,%d,%s)" \
    $((16#${h:0:2})) \
    $((16#${h:2:2})) \
    $((16#${h:4:2})) \
    "$a"
}

BG_RGBA=$(hex_to_rgba "$BG" $GTK_BG_OP)

# -------- FULL FILE REWRITE --------
echo "
/* Core UI Colors */
@define-color window_bg_color $BG_RGBA;
@define-color window_fg_color $FG;
@define-color view_bg_color $BG;
@define-color view_fg_color $FG;

/* Selection and Accents */
@define-color accent_bg_color $ACCENT;
@define-color accent_fg_color $FG;
@define-color accent_color $ACCENT;

/* Header and Sidebar */
@define-color headerbar_bg_color $BG;
@define-color headerbar_fg_color $FG;
@define-color sidebar_bg_color $BG_RGBA;
@define-color sidebar_fg_color $FG;
@define-color sidebar_backdrop_color $BG;

/* Core nm-applets colors */
@define-color nm_bg_color $BG_RGBA;
@define-color nm_fg_color $FG;

" | cat > "$GTK_FILE"

echo "✅ gtk.css written correctly"
killall xdg-desktop-portal-gtk
