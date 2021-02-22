#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

desktop=$(echo $DESKTOP_SESSION)
count=$(xrandr --query | grep " connected" | cut -d" " -f1 | wc -l)

case $desktop in

i3)
    if type "xrandr" >/dev/null; then
        for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload mainbar-i3 -c ~/.config/polybar/config-main.ini &
        done
    else
        polybar --reload mainbar-i3 -c ~/.config/polybar/config-main.ini &
    fi
    # second polybar at bottom
    # if type "xrandr" >/dev/null; then
    #     for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    #         MONITOR=$m polybar --reload mainbar-extra -c ~/.config/polybar/config-extra.ini &
    #     done
    # else
    #     polybar --reload mainbar-extra -c ~/.config/polybar/config-extra.ini &
    # fi
    ;;

bspwm)
    if type "xrandr" >/dev/null; then
        for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload mainbar-bspwm -c ~/.config/polybar/config-main.ini &
        done
    else
        polybar --reload mainbar-bspwm -c ~/.config/polybar/config-main.ini &
    fi
    # second polybar at bottom
    if type "xrandr" >/dev/null; then
        for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
            MONITOR=$m polybar --reload mainbar-extra -c ~/.config/polybar/config-extra.ini &
        done
    else
        polybar --reload mainbar-extra -c ~/.config/polybar/config-extra.ini &
    fi
    ;;
esac
