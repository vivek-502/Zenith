#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

[[ -f "$WAL_JSON" ]] || {
  echo "❌ pywal colors not found: $WAL_JSON" >&2
  exit 1
}



#__________________________________________ Kitty overwrite  ________________________________________________


# required keys (special)
BG=$(jq -r '.special.background // empty' "$WAL_JSON")
FG=$(jq -r '.special.foreground // empty' "$WAL_JSON")
CUR=$(jq -r '.special.cursor // empty' "$WAL_JSON")

# colors.color0..color15
COLOR0=$(jq -r '.colors.color0  // empty' "$WAL_JSON")
COLOR1=$(jq -r '.colors.color1  // empty' "$WAL_JSON")
COLOR2=$(jq -r '.colors.color2  // empty' "$WAL_JSON")
COLOR3=$(jq -r '.colors.color3  // empty' "$WAL_JSON")
COLOR4=$(jq -r '.colors.color4  // empty' "$WAL_JSON")
COLOR5=$(jq -r '.colors.color5  // empty' "$WAL_JSON")
COLOR6=$(jq -r '.colors.color6  // empty' "$WAL_JSON")
COLOR7=$(jq -r '.colors.color7  // empty' "$WAL_JSON")
COLOR8=$(jq -r '.colors.color8  // empty' "$WAL_JSON")
COLOR9=$(jq -r '.colors.color9  // empty' "$WAL_JSON")
COLOR10=$(jq -r '.colors.color10 // empty' "$WAL_JSON")
COLOR11=$(jq -r '.colors.color11 // empty' "$WAL_JSON")
COLOR12=$(jq -r '.colors.color12 // empty' "$WAL_JSON")
COLOR13=$(jq -r '.colors.color13 // empty' "$WAL_JSON")
COLOR14=$(jq -r '.colors.color14 // empty' "$WAL_JSON")
COLOR15=$(jq -r '.colors.color15 // empty' "$WAL_JSON")

# Validate at least the basics are present; fallbacks if empty
: "${BG:="#000000"}"
: "${FG:="#ffffff"}"
: "${CUR:="$FG"}"

: "${COLOR0:="$BG"}"
: "${COLOR1:="$FG"}"
: "${COLOR2:="$FG"}"
: "${COLOR3:="$FG"}"
: "${COLOR4:="$FG"}"
: "${COLOR5:="$FG"}"
: "${COLOR6:="$FG"}"
: "${COLOR7:="$FG"}"
: "${COLOR8:="$FG"}"
: "${COLOR9:="$FG"}"
: "${COLOR10:="$FG"}"
: "${COLOR11:="$FG"}"
: "${COLOR12:="$FG"}"
: "${COLOR13:="$FG"}"
: "${COLOR14:="$FG"}"
: "${COLOR15:="$FG"}"

# ---------------- Map palette into kitty fields (Option A mapping) ----------------
# As requested: simple, predictable mapping:
#   foreground  -> special.foreground
#   background  -> special.background
#   cursor      -> special.cursor
#   cursor_text_color -> special.foreground
#   selection_foreground -> special.foreground
#   selection_background -> colors.color0 (dark)
#   tab bar / active/inactive -> some accents

SELECTION_BG="$COLOR0"
TABBAR_BG="$COLOR7"
ACTIVE_TAB_BG="$COLOR4"
ACTIVE_TAB_FG="$FG"
INACTIVE_TAB_BG="$COLOR7"
INACTIVE_TAB_FG="$COLOR8"

# ---------------- Write entire kitty.conf file (overwrite) ----------------

echo "
# Basic colors
foreground $FG
background $BG

# Cursor
cursor $CUR
cursor_text_color $FG

# Selection
selection_foreground $BG
selection_background $FG

# Tab bar colors
tab_bar_background $TABBAR_BG
active_tab_foreground $ACTIVE_TAB_FG
active_tab_background $ACTIVE_TAB_BG
inactive_tab_foreground $INACTIVE_TAB_FG
inactive_tab_background $INACTIVE_TAB_BG

# Colors
color0  $COLOR0
color1  $COLOR1
color2  $COLOR2
color3  $COLOR3
color4  $COLOR4
color5  $COLOR5
color6  $COLOR6
color7  $COLOR7
color8  $COLOR8
color9  $COLOR9
color10 $COLOR10
color11 $COLOR11
color12 $COLOR12
color13 $COLOR13
color14 $COLOR14
color15 $COLOR15

" | cat > "$THEME_DIR/kitty.conf"

echo "kitty here"

# Reload kitty
pkill -USR1 kitty   
