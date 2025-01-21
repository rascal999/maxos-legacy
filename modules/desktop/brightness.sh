#!/bin/sh

# Get current brightness
current=$(xrandr --verbose | grep -i brightness | cut -f2 -d " ")

case "$1" in
  "up")
    # Increase brightness by 0.1, max at 1.0
    new=$(echo "$current + 0.1" | bc)
    if [ "$(echo "$new <= 1.0" | bc)" -eq 1 ]; then
      xrandr --output eDP-1 --brightness $new
    fi
    ;;
  "down")
    # Decrease brightness by 0.1, min at 0.1
    new=$(echo "$current - 0.1" | bc)
    if [ "$(echo "$new >= 0.1" | bc)" -eq 1 ]; then
      xrandr --output eDP-1 --brightness $new
    fi
    ;;
  *)
    echo "Usage: $0 [up|down]"
    exit 1
    ;;
esac
