#!/usr/bin/env bash
# ~/.config/Zenith/scripts/workspace/manage-workspace.sh

SCRIPT_DIR="$HOME/.config/Zenith/scripts/workspace"
CACHE_DIR="$HOME/.config/Zenith/.cache/workspace"

hyprctl eval "dofile('$HOME/.config/rofi/animations/Walker_anim.lua')"

# Ensure directories exist
mkdir -p "$CACHE_DIR"

# 1. Main Action Menu Selection
OPTIONS="󰁔 Load Workspace\n󰆓 Save Workspace\n󰆴 Delete Workspace"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -theme ~/.config/rofi/walker.rasi -p "Workspace Manager:" -theme-str 'listview {lines: 3;}')

case "$CHOICE" in
    *"Load Workspace"*)
        if [ -f "$SCRIPT_DIR/restore-workspace.sh" ]; then
            bash "$SCRIPT_DIR/restore-workspace.sh"
        else
            notify-send -u critical "Error" "restore-workspace.sh not found."
        fi
        ;;

    *"Save Workspace"*)
        if [ -f "$SCRIPT_DIR/save-workspace.sh" ]; then
            bash "$SCRIPT_DIR/save-workspace.sh"
        else
            notify-send -u critical "Error" "save-workspace.sh not found."
        fi
        ;;

    *"Delete Workspace"*)
        # 2. Build deletion list with matching screenshot icons
        DEL_OPTIONS=""
        while IFS= read -r -d '' dir; do
            [ -d "$dir" ] || continue
            NAME=$(basename "$dir")
            PREVIEW="$dir/preview.png"
            if [ -f "$PREVIEW" ]; then
                DEL_OPTIONS+="${NAME}\0icon\x1f${PREVIEW}\n"
            else
                DEL_OPTIONS+="${NAME}\n"
            fi
        done < <(find "$CACHE_DIR" -maxdepth 1 -mindepth 1 -type d -print0)

        if [ -z "$DEL_OPTIONS" ]; then
            notify-send "Workspace Manager" "No layouts found to delete."
            exit 0
        fi

        TARGET_DEL=$(echo -e "$DEL_OPTIONS" | rofi -dmenu -show-icons -theme "~/.config/rofi/theme-switcher.rasi" -p "Delete Layout:")
        [ -z "$TARGET_DEL" ] && exit 0

        # 3. Clean up target directories safely
        TARGET_DIR="$CACHE_DIR/$TARGET_DEL"
        if [ -d "$TARGET_DIR" ]; then
            rm -rf "$TARGET_DIR"
            notify-send "Workspace Deleted" "Layout '$TARGET_DEL' and its previews were removed."
        else
            notify-send -u critical "Error" "Could not find layout path."
        fi
        ;;
    *)
        exit 0
        ;;
esac
