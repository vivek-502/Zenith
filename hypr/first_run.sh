#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
AUTOSTART_LUA="$HOME/.config/hypr/autostart.lua"
SCRIPT_BASENAME="$(basename "$SCRIPT_PATH")"   # first_run.sh
awww img ~/.config/Zenith/backgrounds/dark/4.jpg

kitty --class floating-terminal -e bash -lc '
set -euo pipefail

SCRIPT_PATH="'"$SCRIPT_PATH"'"
AUTOSTART_LUA="'"$AUTOSTART_LUA"'"
SCRIPT_BASENAME="'"$SCRIPT_BASENAME"'"

echo "Thanks for installation of Zenith"
echo
echo "Keybindings:"
echo "  • Press SUPER + K           -> learn all keybindings"
echo "  • Press SUPER + ALT + Space -> main menu for all options"
echo
echo "You can read docs at:"
echo "  $HOME/.config/Zenith/docs"
echo
echo "Press ENTER to close."
read -r _

# Delete the autostart line(s) that start this script
if [ -f "$AUTOSTART_LUA" ]; then
  tmp="$(mktemp)"
  # Keep all lines except the ones that launch first_run.sh via exec_cmd
  while IFS= read -r line; do
    if [[ "$line" == *"exec_cmd"* && "$line" == *"$SCRIPT_BASENAME"* ]]; then
      continue
    fi
    echo "$line" >> "$tmp"
  done < "$AUTOSTART_LUA"
  cat "$tmp" > "$AUTOSTART_LUA"
  rm -f "$tmp"
fi

# Self-delete
rm -f -- "$SCRIPT_PATH"
'
