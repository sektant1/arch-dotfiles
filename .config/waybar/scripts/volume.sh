#!/bin/bash
# ── volume.sh ─────────────────────────────────────────────
# Description: Shows current audio volume with ASCII bar + tooltip
# Usage: Waybar `custom/volume` every 2s
# Dependencies: wpctl, awk
# ───────────────────────────────────────────────────────────

# Uma única chamada ao wpctl (era 2 antes)
raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
# raw: "Volume: 0.50" ou "Volume: 0.50 [MUTED]"

vol_raw=$(echo "$raw" | awk '{print $2}')
vol_int=$(awk "BEGIN {printf \"%d\", $vol_raw * 100}")
is_muted=$(echo "$raw" | grep -q MUTED && echo true || echo false)

# Get default sink name (uma única chamada wpctl status)
sink=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep '\*' | cut -d'.' -f2- | sed 's/^\s*//; s/\[.*//')

# Icon logic
if [ "$is_muted" = true ]; then
  icon=""
  vol_int=0
elif [ "$vol_int" -lt 50 ]; then
  icon=""
else
  icon=""
fi

# ASCII bar
filled=$((vol_int / 10))
empty=$((10 - filled))
bar=$(printf '█%.0s' $(seq 1 $filled))
pad=$(printf '░%.0s' $(seq 1 $empty))
ascii_bar="[$bar$pad]"

# Color logic
if [ "$is_muted" = true ] || [ "$vol_int" -lt 10 ]; then
  fg="#bf616a"
elif [ "$vol_int" -lt 50 ]; then
  fg="#fab387"
else
  fg="#56b6c2"
fi

# Tooltip
if [ "$is_muted" = true ]; then
  tooltip="Audio: Muted\nOutput: $sink"
else
  tooltip="Audio: $vol_int%\nOutput: $sink"
fi

echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $vol_int%</span>\",\"tooltip\":\"$tooltip\"}"
