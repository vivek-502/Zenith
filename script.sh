#!/bin/bash

# --- Setup and Error Handling ---
set -e # Exit immediately if a command fails
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

echo "#####################################################"
echo "#          Hyprland Configuration Installer         #"
echo "#####################################################"
echo ""
echo "WARNING: This script will replace your existing configurations in ~/.config/"
echo "It is highly recommended to have a backup before proceeding."
echo ""

# --- Backup Logic ---
read -rp "Have you already backed up your configs? (y/N): " backed_up
if [[ ! $backed_up =~ ^[yY]$ ]]; then
    echo "Creating a backup of ~/.config/* and .bashrc to ~/dotfiles-backup/..."
    mkdir -p ~/dotfiles-backup
    # Backup config folder and bashrc
    cp -rf ~/.config ~/dotfiles-backup/ 2>/dev/null || true
    cp -f ~/.bashrc ~/dotfiles-backup/.bashrc_backup 2>/dev/null || true
    echo "Backup complete."
else
    echo "Proceeding with installation..."
fi

# --- SDDM / Display Manager Logic ---
INSTALL_SDDM=true
if systemctl list-unit-files | grep -E 'gdm|sddm|lightdm|lxdm|ly|greetd' | grep -q 'enabled'; then
    echo ""
    echo "Detected an existing display manager already enabled."
    read -rp "Would you like to skip installing/enabling SDDM? (y/N): " skip_sddm
    if [[ $skip_sddm =~ ^[yY]$ ]]; then
        INSTALL_SDDM=false
    fi
fi

# --- AUR Helper Setup (yay) ---
if ! command -v yay &> /dev/null; then
    echo "Installing yay AUR helper..."
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
    cd /tmp/yay-bin && makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
else
    echo "yay is already installed."
fi

# --- Package Arrays ---
PACMAN_CORE=(hyprland wayland wayland-protocols xdg-desktop-portal-hyprland qt5-wayland qt6-wayland)
[ "$INSTALL_SDDM" = true ] && PACMAN_CORE+=("sddm")

NETWORK_PKGS=(networkmanager wpa_supplicant wireless_tools network-manager-applet)
BLUETOOTH_PKGS=(bluez bluez-utils blueman bluez-obex)
AUDIO_PKGS=(pipewire pipewire-pulse pipewire-alsa)
DESKTOP_ESSENTIALS=(polkit-gnome brightnessctl power-profiles-daemon)
HYPR_DEPS=(firefox yt-dlp unzip grim slurp kitty nautilus waybar rofi-wayland python-pywal imagemagick swaync awww hypridle hyprlock hyprpicker hyprshot cliphist mpv jq viewnior gnome-text-editor)
FONTS=(noto-fonts noto-fonts-emoji ttf-dejavu ttf-liberation ttf-jetbrains-mono-nerd)
AUR_PKGS=(ani-cli wiremix ocr4linux-git)

# --- Installation ---
echo "Installing necessary packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_CORE[@]}" "${NETWORK_PKGS[@]}" "${BLUETOOTH_PKGS[@]}" "${AUDIO_PKGS[@]}" "${DESKTOP_ESSENTIALS[@]}" "${HYPR_DEPS[@]}" "${FONTS[@]}"

echo "Installing special packages from AUR..."
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# --- Services ---
echo "Enabling services..."
sudo systemctl enable --now power-profiles-daemon bluetooth NetworkManager
[ "$INSTALL_SDDM" = true ] && sudo systemctl enable sddm

# --- Conflict Removal ---
sudo pacman -Rns mako dunst --noconfirm 2>/dev/null || true

# --- Config Deployment ---
echo "Applying new configurations..."
CONFIG_DIRS=(rofi swaync hypr waybar gtk-3.0 gtk-4.0 kitty Zenith)

# Fix: Use SCRIPT_DIR for bashrc
if [ -f "$SCRIPT_DIR/.bashrc" ]; then
    cp -f "$SCRIPT_DIR/.bashrc" ~/.bashrc

fi

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$HOME/.config/$dir" ]; then
        rm -rf "$HOME/.config/$dir"
    fi
    mkdir -p "$HOME/.config/$dir"
    if [ -d "$SCRIPT_DIR/$dir" ]; then
        cp -rf "$SCRIPT_DIR/$dir/"* "$HOME/.config/$dir/"
    fi
done

# --- Final Prompt ---
echo ""
echo "Installation and configuration complete!"
read -rp "Reboot now to apply all changes? (y/N): " reboot_reply
if [[ $reboot_reply =~ ^[yY]$ ]]; then
    echo "Rebooting..."
    reboot
else
    echo "Please remember to reboot later."
    exit 0
fi
