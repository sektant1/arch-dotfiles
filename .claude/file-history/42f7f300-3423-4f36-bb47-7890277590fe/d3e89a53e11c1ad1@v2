#!/bin/bash
# ── battery.sh ─────────────────────────────────────────────
# Description: Shows battery % with ASCII bar + dynamic tooltip
# Usage: Waybar `custom/battery` every 10s
# Dependencies: upower, awk, seq, printf
#  ──────────────────────────────────────────────────────────

capacity=$(cat /sys/class/power_supply/BAT0/capacity)
status=$(cat /sys/class/power_supply/BAT0/status)

# Get detailed info from upower (uma única chamada em vez de duas)
upower_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)
time_to_empty=$(echo "$upower_info" | awk -F: '/time to empty/ {print $2}' | xargs)
time_to_full=$(echo "$upower_info" | awk -F: '/time to full/ {print $2}' | xargs)

# Icons
charging_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
default_icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)

index=$((capacity / 10))
[ $index -ge 10 ] && index=9

if [[ "$status" == "Charging" ]]; then
    icon=${charging_icons[$index]}
elif [[ "$status" == "Full" ]]; then
    icon="󰂅"
else
    icon=${default_icons[$index]}
fi

# ASCII bar
filled=$((capacity / 10))
empty=$((10 - filled))
bar=$(printf '█%.0s' $(seq 1 $filled))
pad=$(printf '░%.0s' $(seq 1 $empty))
ascii_bar="[$bar$pad]"

# Color thresholds
if [ "$capacity" -lt 20 ]; then
    fg="#bf616a"  # red
elif [ "$capacity" -lt 55 ]; then
    fg="#fab387"  # orange
else
    fg="#56b6c2"  # cyan
fi

# Tooltip
tooltip="$icon Battery: ${capacity}%\nStatus: $status"
if [[ "$status" == "Charging" ]] && [[ -n "$time_to_full" ]]; then
    tooltip="$tooltip\nTime to full: $time_to_full"
elif [[ -n "$time_to_empty" ]]; then
    tooltip="$tooltip\nTime to empty: $time_to_empty"
fi

# JSON output
echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $capacity%</span>\",\"tooltip\":\"$tooltip\"}"
