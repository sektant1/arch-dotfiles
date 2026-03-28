#!/bin/bash
# workspace-signal.sh — Escuta o socket IPC do Hyprland e manda SIGRTMIN+1
# pro waybar atualizar os workspaces apenas quando há mudança real.
# Muito mais eficiente que polling a cada 1s.

SOCKET="/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -u "UNIX-CONNECT:$SOCKET" - | while IFS= read -r line; do
    case "$line" in
        workspace>>*|focusedmon>>*|moveworkspace>>*|activewindow>>*|closewindow>>*)
            pkill -RTMIN+1 waybar
            ;;
    esac
done
