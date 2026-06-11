#!/usr/bin/env bash

# direct-push-to-talk.sh - Monitors mouse side button and emulates Super+Tab using xdotool
# Author: Roo
# Updated: 2026-06-11 (xdotool version)

# Stable mouse event device path for Logitech USB Receiver
MOUSE_DEVICE_PATH="/dev/input/by-id/usb-Logitech_USB_Receiver-event-mouse"

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Direct Push-to-Talk Script (xdotool Version) ===${NC}"
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

# evsieve will run in the foreground.
# BTN_SIDE (key code 275) down (1) runs xdotool keydown.
# BTN_SIDE up (0) runs xdotool keyup.
evsieve \
  --input "${MOUSE_DEVICE_PATH}" grab \
  --hook "key:%275:1" "exec-shell=xdotool keydown Super_L keydown Tab" \
  --hook "key:%275:0" "exec-shell=xdotool keyup Tab keyup Super_L" \
  --block "key:%275" \
  --output
