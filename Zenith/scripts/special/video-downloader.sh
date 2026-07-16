#!/usr/bin/env bash

# video-downloader-tui.sh

kitty --class floating-terminal --title "Video Downloader" bash -c '

clear

# ===== Banner =====
echo "======================================="
echo "         VIDEO DOWNLOADER"
echo "======================================="
echo ""

# ===== Dependency Check =====
if ! command -v yt-dlp &> /dev/null; then
    echo "Error: yt-dlp is not installed."
    echo ""
    echo "Install it from:"
    echo "https://github.com/yt-dlp/yt-dlp"
    echo ""
    read -p "Press Enter to close..."
    exit 1
fi

# ===== Ask URL =====
while true; do
    read -p "Enter video URL: " URL

    if [[ -n "$URL" ]]; then
        break
    fi

    echo "URL cannot be empty."
    echo ""
done

echo ""

# ===== Ask Cookies =====
read -p "Cookies file path (optional): " COOKIES

echo ""

# ===== Ask Save Location =====
read -p "Save location [default: ~/Downloads]: " OUTPUT_DIR

# Default directory
if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="$HOME/Downloads"
fi

mkdir -p "$OUTPUT_DIR"

echo ""
echo "======================================="
echo "Starting download..."
echo "======================================="
echo ""

# ===== Build Command =====
CMD=(
    yt-dlp
    -f "bestvideo+bestaudio/best"
    --merge-output-format mp4
    -o "$OUTPUT_DIR/%(title)s.%(ext)s"
)

# Add cookies if provided
if [[ -n "$COOKIES" ]]; then
    CMD+=(--cookies "$COOKIES")
fi

# Add URL
CMD+=("$URL")

# ===== Run Download =====
if "${CMD[@]}"; then
    echo ""
    echo "======================================="
    echo "Download completed successfully!"
    echo "Saved to: $OUTPUT_DIR"
    echo "======================================="
else
    echo ""
    echo "======================================="
    echo "Download failed."
    echo ""
    echo "Some websites block restricted content."
    echo "Try using a cookies.txt file."
    echo "======================================="
fi

echo ""
read -p "Press Enter to close..."

'
