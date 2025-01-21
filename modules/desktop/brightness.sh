#!/bin/sh
# Set initial brightness and store the value
xrandr --output eDP-1 --brightness 0.3
echo "0.3" > ~/.config/brightness
