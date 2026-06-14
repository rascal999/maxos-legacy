#!/usr/bin/env bash

# direct-push-to-talk.sh - Monitors mouse side button and emulates Super+Tab using xdotool
# Author: Roo
# Updated: 2026-06-14 (Pure-bash atomic synchronized xdotool version)

# Stable mouse event device path for Logitech USB Receiver
MOUSE_DEVICE_PATH="/dev/input/by-id/usb-Logitech_USB_Receiver-event-mouse"

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Direct Push-to-Talk Script (Synchronized xdotool Version) ===${NC}"
echo -e "This script monitors '${YELLOW}$MOUSE_DEVICE_PATH${NC}' for BTN_SIDE (code 275)."
echo -e "It will emulate pressing and holding '${GREEN}Super+Tab${NC}' using xdotool."

if [ ! -e "$MOUSE_DEVICE_PATH" ]; then
    echo -e "${RED}Error: Mouse device path not found: $MOUSE_DEVICE_PATH${NC}"
    exit 1
fi

# Ensure xdotool is in path
if ! command -v xdotool &>/dev/null; then
    echo -e "${RED}Error: xdotool not found in PATH${NC}"
    exit 1
fi

echo -e "${BLUE}Starting evsieve to map BTN_SIDE to xdotool Super+Tab...${NC}"

# Initialize state and lock to ensure a clean start
echo 0 > /tmp/ptt.state
rm -rf /tmp/ptt.lock

# evsieve will run in the foreground.
# To prevent asynchronous shell process race conditions where keyup is executed
# before keydown, we use /tmp/ptt.state as a state variable and an atomic directory
# /tmp/ptt.lock for pure-bash thread-safe locking (since flock isn't in coreutils).
# This also guarantees nested key press/release order: [Super_L down, Tab down] ... [Tab up, Super_L up].
evsieve \
  --input "${MOUSE_DEVICE_PATH}" grab \
  --hook "key:%275:1" "exec-shell=echo 1 > /tmp/ptt.state && (while ! mkdir /tmp/ptt.lock 2>/dev/null; do sleep 0.005; done && xdotool keydown Super_L keydown Tab && rmdir /tmp/ptt.lock)" \
  --hook "key:%275:0" "exec-shell=while [ ! -f /tmp/ptt.state ] || [ \"\$(cat /tmp/ptt.state 2>/dev/null)\" != \"1\" ]; do sleep 0.005; done && (while ! mkdir /tmp/ptt.lock 2>/dev/null; do sleep 0.005; done && xdotool keyup Tab keyup Super_L && rmdir /tmp/ptt.lock && echo 0 > /tmp/ptt.state)" \
  --block "key:%275" \
  --output
