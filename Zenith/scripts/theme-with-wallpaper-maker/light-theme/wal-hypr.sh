#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/env.sh"

[[ -f "$WAL_JSON" ]] || {
  echo "❌ pywal colors not found: $WAL_JSON" >&2
  exit 1
}


#__________________________________________  Hypr _______________________________________________

# ---------------- extract colors ----------------
BG=$(jq -r '.special.background' "$WAL_JSON")
FG=$(jq -r '.special.foreground' "$WAL_JSON")

C3=$(jq -r '.colors.color3' "$WAL_JSON")
C4=$(jq -r '.colors.color4' "$WAL_JSON")
C5=$(jq -r '.colors.color5' "$WAL_JSON")
C6=$(jq -r '.colors.color6' "$WAL_JSON")

# ---------------- helpers ----------------

# hex → hyprland rgba(RRGGBBAA)
hex_hypr_rgba() {
  local h="${1#\#}"
  local a="${2:-ee}"
  printf "rgba(%s%s)" "$h" "$a"
}

# hex → rgba(r,g,b,a)
hex_rgba_float() {
  local h="${1#\#}"
  local a="${2:-1.0}"
  printf "rgba(%d,%d,%d,%s)" \
    $((16#${h:0:2})) \
    $((16#${h:2:2})) \
    $((16#${h:4:2})) \
    "$a"
}

# ---------------- hyprland colors ----------------
ACTIVE_1=$(hex_hypr_rgba "$C3" "ee")
ACTIVE_2=$(hex_hypr_rgba "$C5" "ee")
INACTIVE=$(hex_hypr_rgba "$BG" "aa")

# ---------------- hyprlock colors ----------------
LOCK_BG=$(hex_rgba_float "$BG" 1.0)
LOCK_ACCENT=$(hex_rgba_float "$C4" 1.0)
LOCK_FG=$(hex_rgba_float "$FG" 1.0)

# ---------------- rewrite hyprland.conf ----------------
echo "
hl.config({

    general = {
        col = {
            active_border   = { colors = {'$ACTIVE_1', '$ACTIVE_2'}, angle = 45 },
            inactive_border = '$INACTIVE',
        },
    },

    group = {
        -- Group border colors are now nested inside a 'col' sub-table
        col = {
            border_active = '$ACTIVE_1',
            border_inactive = '$INACTIVE',
            border_locked_active = '$ACTIVE_2',
            border_locked_inactive = '$INACTIVE',
        },

        -- Group bar (tab) appearance
        groupbar = {
            enabled = true,
            font_size = 10,
            gradients = true,
            height = 14,
            render_titles = true,
            scrolling = true,

            -- Tab colors are also nested inside a 'col' sub-table
            col = {
                active = '$ACTIVE_1',
                inactive = '$INACTIVE',
                locked_active = '$ACTIVE_2',
                locked_inactive = '$INACTIVE',
            },
        },
    },
})
" | cat > "$THEME_DIR/hyprland.lua"

# ---------------- rewrite hyprlock.conf ----------------
echo "
\$color = $LOCK_BG
\$inner_color = $LOCK_BG
\$outer_color = $LOCK_ACCENT
\$font_color = $LOCK_FG
\$check_color = $LOCK_ACCENT
" | cat > "$THEME_DIR/hyprlock.conf"


hyprctl reload