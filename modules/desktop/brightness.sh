#!/bin/sh

# Default color temperature (matching i3 config)
TEMP=3500

# Store brightness state in a file
BRIGHTNESS_FILE="/tmp/redshift_brightness"

# Initialize brightness file if it doesn't exist
if [ ! -f "$BRIGHTNESS_FILE" ]; then
    echo "0.6" > "$BRIGHTNESS_FILE"  # Default brightness matching i3 config
fi

# Get current brightness from file
current=$(cat "$BRIGHTNESS_FILE")

case "$1" in
  "up")
    # Increase brightness by 0.1, max at 1.0
    new=$(echo "$current + 0.1" | bc)
    if [ "$(echo "$new <= 1.0" | bc)" -eq 1 ]; then
      redshift -O $TEMP -b $new && echo "$new" > "$BRIGHTNESS_FILE"
    fi
    ;;
  "down")
    # Decrease brightness by 0.1, min at 0.1
    new=$(echo "$current - 0.1" | bc)
    if [ "$(echo "$new >= 0.1" | bc)" -eq 1 ]; then
      redshift -O $TEMP -b $new && echo "$new" > "$BRIGHTNESS_FILE"
    fi
    ;;
  "reset")
    # Reset to default values
    redshift -O $TEMP -b 0.6 && echo "0.6" > "$BRIGHTNESS_FILE"
    ;;
  *)
    echo "Usage: $0 [up|down|reset]"
    exit 1
    ;;
esac
