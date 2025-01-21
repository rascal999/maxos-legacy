#!/bin/sh

# Default color temperature
TEMP=3500

# Get current brightness from redshift
current=$(redshift -p 2>/dev/null | grep -i brightness | cut -d ' ' -f3)

# If no current brightness found, use default
if [ -z "$current" ]; then
    current=0.6
fi

case "$1" in
  "up")
    # Increase brightness by 0.1, max at 1.0
    new=$(echo "$current + 0.1" | bc)
    if [ "$(echo "$new <= 1.0" | bc)" -eq 1 ]; then
      redshift -O $TEMP -b $new
    fi
    ;;
  "down")
    # Decrease brightness by 0.1, min at 0.1
    new=$(echo "$current - 0.1" | bc)
    if [ "$(echo "$new >= 0.1" | bc)" -eq 1 ]; then
      redshift -O $TEMP -b $new
    fi
    ;;
  "reset")
    # Reset to default values
    redshift -O $TEMP -b 0.6
    ;;
  *)
    echo "Usage: $0 [up|down|reset]"
    exit 1
    ;;
esac
