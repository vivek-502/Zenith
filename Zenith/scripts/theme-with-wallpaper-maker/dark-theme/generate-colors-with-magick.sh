#!/usr/bin/env bash

# Check if an image path was provided
if [[ -z "${1:-}" ]]; then
    echo "Usage: $0 /path/to/wallpaper.jpg"
    exit 1
fi

WALLPAPER="$1"

# Check if file exists
if [[ ! -f "$WALLPAPER" ]]; then
    echo "Error: File $WALLPAPER not found."
    exit 1
fi



# ---------- Extract 16 Dominant Colors ----------
# 1. Resize for speed
# 2. Modulate (120 saturation) to make colors pop
# 3. Quantize to 16 colors
mapfile -t IM_COLORS < <(magick "$WALLPAPER" \
  -resize 256x256^ \
  -modulate 100,120 \
  -colors 16 \
  -format "%c" histogram:info: \
  | sort -nr \
  | grep -E -o '#[A-Fa-f0-9]{6}' \
  | tr '[:upper:]' '[:lower:]')

# Pad the array if the image is too simple (e.g. solid colors)
while [ ${#IM_COLORS[@]} -lt 16 ]; do
    IM_COLORS+=("${IM_COLORS[@]}")
done

hex_to_hsl_with_l() {
    local hex="${1#\#}"   # remove #
    local new_l="$2"      # desired lightness (0-100)

    # extract RGB (0-255)
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))

    awk -v r="$r" -v g="$g" -v b="$b" -v new_l="$new_l" '
    BEGIN {
        r/=255; g/=255; b/=255

        max=r; if(g>max)max=g; if(b>max)max=b
        min=r; if(g<min)min=g; if(b<min)min=b
        d=max-min

        # lightness
        l=(max+min)/2

        if (d==0) {
            h=0
            s=0
        } else {
            s = (l>0.5) ? d/(2-max-min) : d/(max+min)

            if (max==r)      h=(g-b)/d + (g<b?6:0)
            else if (max==g) h=(b-r)/d + 2
            else             h=(r-g)/d + 4

            h*=60
        }

        printf "hsl(%d, %.0f%%, %d%%)\n", h, s*100, new_l
    }'
}


hsl_to_hex() {
    local input="$1"

    # extract numbers
    local h=$(echo "$input" | sed -E 's/hsl\(([0-9.]+), *([0-9.]+)%, *([0-9.]+)%\)/\1/')
    local s=$(echo "$input" | sed -E 's/hsl\(([0-9.]+), *([0-9.]+)%, *([0-9.]+)%\)/\2/')
    local l=$(echo "$input" | sed -E 's/hsl\(([0-9.]+), *([0-9.]+)%, *([0-9.]+)%\)/\3/')

    awk -v h="$h" -v s="$s" -v l="$l" '
    function hue2rgb(p,q,t){
        if(t<0)t+=1
        if(t>1)t-=1
        if(t<1.0/6)return p+(q-p)*6*t
        if(t<1.0/2)return q
        if(t<2.0/3)return p+(q-p)*(2.0/3-t)*6
        return p
    }
    BEGIN{
        h/=360; s/=100; l/=100

        if(s==0){
            r=g=b=l
        } else {
            q = (l < 0.5) ? l*(1+s) : l+s-l*s
            p = 2*l-q
            r = hue2rgb(p,q,h+1.0/3)
            g = hue2rgb(p,q,h)
            b = hue2rgb(p,q,h-1.0/3)
        }

        r=int(r*255+0.5)
        g=int(g*255+0.5)
        b=int(b*255+0.5)

        printf("#%02x%02x%02x\n", r,g,b)
    }'
}


COLOR_0_HSL=$(hex_to_hsl_with_l "${IM_COLORS[0]}" 10)
COLOR_1_HSL=$(hex_to_hsl_with_l "${IM_COLORS[1]}" 30)
COLOR_2_HSL=$(hex_to_hsl_with_l "${IM_COLORS[2]}" 40)
COLOR_3_HSL=$(hex_to_hsl_with_l "${IM_COLORS[3]}" 45)
COLOR_4_HSL=$(hex_to_hsl_with_l "${IM_COLORS[4]}" 50)
COLOR_5_HSL=$(hex_to_hsl_with_l "${IM_COLORS[5]}" 55)
COLOR_6_HSL=$(hex_to_hsl_with_l "${IM_COLORS[6]}" 60)
COLOR_7_HSL=$(hex_to_hsl_with_l "${IM_COLORS[7]}" 65)
COLOR_8_HSL=$(hex_to_hsl_with_l "${IM_COLORS[8]}" 70)
COLOR_9_HSL=$(hex_to_hsl_with_l "${IM_COLORS[9]}" 75)
COLOR_10_HSL=$(hex_to_hsl_with_l "${IM_COLORS[10]}" 80)
COLOR_11_HSL=$(hex_to_hsl_with_l "${IM_COLORS[11]}" 80)
COLOR_12_HSL=$(hex_to_hsl_with_l "${IM_COLORS[12]}" 85)
COLOR_13_HSL=$(hex_to_hsl_with_l "${IM_COLORS[13]}" 85)
COLOR_14_HSL=$(hex_to_hsl_with_l "${IM_COLORS[14]}" 90)
COLOR_15_HSL=$(hex_to_hsl_with_l "${IM_COLORS[15]}" 90)

COLOR_0=$(hsl_to_hex "$COLOR_0_HSL")
COLOR_1=$(hsl_to_hex "$COLOR_1_HSL")
COLOR_2=$(hsl_to_hex "$COLOR_2_HSL")
COLOR_3=$(hsl_to_hex "$COLOR_3_HSL")
COLOR_4=$(hsl_to_hex "$COLOR_4_HSL")
COLOR_5=$(hsl_to_hex "$COLOR_5_HSL")
COLOR_6=$(hsl_to_hex "$COLOR_6_HSL")
COLOR_7=$(hsl_to_hex "$COLOR_7_HSL")
COLOR_8=$(hsl_to_hex "$COLOR_8_HSL")
COLOR_9=$(hsl_to_hex "$COLOR_9_HSL")
COLOR_10=$(hsl_to_hex "$COLOR_10_HSL")
COLOR_11=$(hsl_to_hex "$COLOR_11_HSL")
COLOR_12=$(hsl_to_hex "$COLOR_12_HSL")
COLOR_13=$(hsl_to_hex "$COLOR_13_HSL")
COLOR_14=$(hsl_to_hex "$COLOR_14_HSL")
COLOR_15=$(hsl_to_hex "$COLOR_15_HSL")


BG=$(hsl_to_hex "$COLOR_0_HSL")
FG=$(hsl_to_hex "$COLOR_15_HSL")


# ---------- Generate colors.json (Pywal Format) ----------
CACHE_FILE="$HOME/.cache/wal/colors.json"
mkdir -p "$(dirname "$CACHE_FILE")"

cat > "$CACHE_FILE" <<EOF
{
    "wallpaper": "$WALLPAPER",
    "alpha": "100",
    "special": {
        "background": "$BG",
        "foreground": "$FG",
        "cursor": "$FG"
    },
    "colors": {
        "color0": "$COLOR_0",
        "color1": "$COLOR_1",
        "color2": "$COLOR_2",
        "color3": "$COLOR_3",
        "color4": "$COLOR_4",
        "color5": "$COLOR_5",
        "color6": "$COLOR_6",
        "color7": "$COLOR_7",
        "color8": "$COLOR_8",
        "color9": "$COLOR_9",
        "color10": "$COLOR_10",
        "color11": "$COLOR_11",
        "color12": "$COLOR_12",
        "color13": "$COLOR_13",
        "color14": "$COLOR_14",
        "color15": "$COLOR_15"
    }
}
EOF

echo "Palette generated for $(basename "$WALLPAPER") at $CACHE_FILE"
