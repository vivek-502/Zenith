#!/usr/bin/env bash
# ~/.config/Zenith/scripts/workspace/app-map.sh

CLASS="$1"

# Map the Hyprland window class to its startup command
case "$CLASS" in
    "kitty")
        echo "kitty"
        ;;
    "firefox")
        echo "firefox"
        ;;
    "thunar")
        echo "thunar"
        ;;
    "code-oss" | "Code")
        echo "code"
        ;;
    "discord")
        echo "discord"
        ;;
    "spotify")
        echo "spotify"
        ;;
    "org.gnome.Nautilus")
        echo "nautilus"
        ;;
     "org.gnome.NetworkDisplays")
        echo "gnome-network-displays"
        ;;
     "io.missioncenter.MissionCenter")
        echo "missioncenter"
        ;;
     "org.gnome.TextEditor")
        echo "gnome-text-editor"
        ;;
    # -------------------------------------------------------------
    # Add your custom window classes and their execution strings here
    # -------------------------------------------------------------
    *)
        # Return exit code 1 if no mapping is found
        exit 1
        ;;
esac
