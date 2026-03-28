#!/bin/bash
# toggle-edp.sh — Ativa/desativa o monitor eDP-1

if hyprctl monitors | grep -q "^Monitor eDP-1"; then
    hyprctl keyword monitor "eDP-1, disable"
else
    hyprctl keyword monitor "eDP-1, preferred, auto, 1"
fi
