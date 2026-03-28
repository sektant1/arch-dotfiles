#!/bin/bash
# ── brightness.sh ─────────────────────────────────────────
# Description: Shows current brightness with ASCII bar + tooltip
# Usage: Waybar `custom/brightness` every 2s
# Dependencies: brightnessctl, seq, printf
#  ─────────────────────────────────────────────────────────

# Uma única chamada ao invés de três (get, max, --machine-readable)
IFS=, read -r device _ current max _ < <(brightnessctl --machine-readable)
percent=$((current * 100 / max))

# Build ASCII bar
filled=$((percent / 10))
empty=$((10 - filled))
bar=$(printf '█%.0s' $(seq 1 $filled))
pad=$(printf '░%.0s' $(seq 1 $empty))
ascii_bar="[$bar$pad]"

icon="󰛨"

# Color thresholds
if [ "$percent" -lt 20 ]; then
    fg="#bf616a"
elif [ "$percent" -lt 55 ]; then
    fg="#fab387"
else
    fg="#56b6c2"
fi

tooltip="Brightness: $percent%\nDevice: $device"

echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $percent%</span>\",\"tooltip\":\"$tooltip\"}"
