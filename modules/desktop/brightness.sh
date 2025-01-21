#!/bin/sh

# Default color temperature
TEMP=3500

# Store brightness state
BRIGHTNESS_FILE="/tmp/redshift_brightness"

# Initialize brightness file if needed
[ ! -f "$BRIGHTNESS_FILE" ] && echo "0.6" > "$BRIGHTNESS_FILE"

current=$(cat "$BRIGHTNESS_FILE")

case "$1" in
  "up")
    new=$(echo "$current + 0.1" | bc)
    [ $(echo "$new <= 1.0" | bc) -eq 1 ] && redshift -O $TEMP -b $new && echo "$new" > "$BRIGHTNESS_FILE"
    ;;
  "down")
    new=$(echo "$current - 0.1" | bc)
    [ $(echo "$new >= 0.1" | bc) -eq 1 ] && redshift -O $TEMP -b $new && echo "$new" > "$BRIGHTNESS_FILE"
    ;;
  "reset")
    redshift -O $TEMP -b 0.6 && echo "0.6" > "$BRIGHTNESS_FILE"
    ;;
  *)
    echo "Usage: $0 [up|down|reset]"
    exit 1
    ;;
esac
