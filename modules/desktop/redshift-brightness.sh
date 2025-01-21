#!/bin/sh

# Default color temperature
TEMP=3500

# Store brightness state
BRIGHTNESS_FILE="/tmp/redshift_brightness"

# Initialize brightness file if needed
[ ! -f "$BRIGHTNESS_FILE" ] && echo "0.5" > "$BRIGHTNESS_FILE"

current=$(cat "$BRIGHTNESS_FILE")

case "$1" in
  "up")
    new=$(echo "$current + 0.1" | bc)
    if [ $(echo "$new <= 1.0" | bc) -eq 1 ]; then
      redshift -P -O $TEMP -b $new
      echo "$new" > "$BRIGHTNESS_FILE"
      echo "$new"
    else
      echo "1.0"
    fi
    ;;
  "down")
    new=$(echo "$current - 0.1" | bc)
    if [ $(echo "$new >= 0.1" | bc) -eq 1 ]; then
      redshift -P -O $TEMP -b $new
      echo "$new" > "$BRIGHTNESS_FILE"
      echo "$new"
    else
      echo "0.1"
    fi
    ;;
  "get")
    echo "$current"
    ;;
  "set")
    if [ -n "$2" ] && [ $(echo "$2 >= 0.1" | bc) -eq 1 ] && [ $(echo "$2 <= 1.0" | bc) -eq 1 ]; then
      redshift -P -O $TEMP -b $2
      echo "$2" > "$BRIGHTNESS_FILE"
      echo "$2"
    fi
    ;;
  *)
    echo "Usage: $0 [up|down|get|set <value>]"
    exit 1
    ;;
esac
