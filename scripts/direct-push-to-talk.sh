#!/usr/bin/env bash

# direct-push-to-talk.sh - Direct event monitoring for push-to-talk functionality
# Author: Roo
# Date: 2025-05-21

# This script directly monitors mouse button events and controls the microphone
# without relying on keyd. It's an alternative approach if keyd isn't working.

# Audio device to control
AUDIO_DEVICE="94" # Jabra EVOLVE 20 MS Mono (ID from wpctl status)
# Mouse event device for G502 X (as identified by user)
MOUSE_DEVICE_PATH="/dev/input/event3"

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Direct Push-to-Talk Script ===${NC}"
echo -e "This script monitors '${YELLOW}$MOUSE_DEVICE_PATH${NC}' for BTN_SIDE (code 275)."
echo -e "It will control microphone ID '${YELLOW}$AUDIO_DEVICE${NC}'."
echo -e "Run this script with ${GREEN}sudo${NC}."

# Check if running as root - necessary for evtest on input devices
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: This script needs to be run as root (sudo) to access input devices with evtest.${NC}"
  exit 1
fi

if [ ! -e "$MOUSE_DEVICE_PATH" ]; then
    echo -e "${RED}Error: Mouse device path not found: $MOUSE_DEVICE_PATH${NC}"
    echo -e "Please verify this path. You can list devices with 'ls /dev/input/event*'"
    echo -e "And identify your mouse with 'sudo evtest' (run it and select devices)."
    exit 1
fi

# Determine user context for running wpctl
WPCTL_CMD_PREFIX=""
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
  USER_UID=$(id -u "$SUDO_USER")
  if [ -n "$USER_UID" ]; then
    WPCTL_CMD_PREFIX="sudo -u $SUDO_USER XDG_RUNTIME_DIR=/run/user/$USER_UID DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_UID/bus "
    echo -e "Will run wpctl commands as user: ${GREEN}$SUDO_USER (UID: $USER_UID)${NC}"
  else
    echo -e "${RED}Warning: Could not determine UID for $SUDO_USER. wpctl might fail if run as root.${NC}"
  fi
else
  echo -e "${RED}Warning: SUDO_USER not found or is root. wpctl commands will run as root and might fail to connect to user's PipeWire.${NC}"
  echo -e "         It's best to run this script via 'sudo ./your_script_name.sh' as a regular user."
fi

echo -e "${GREEN}Monitoring mouse device: $MOUSE_DEVICE_PATH${NC}"
echo -e "${GREEN}Controlling audio device: $AUDIO_DEVICE${NC}"
echo -e "${YELLOW}Press and hold your designated mouse button. Release to mute.${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop this script.${NC}"

# Ensure microphone is initially muted
echo "Initializing microphone to muted state..."
# Attempt to run wpctl as the logged-in user if sudo is used
echo -e "Initializing microphone to ${RED}MUTED${NC} state..."
${WPCTL_CMD_PREFIX}wpctl set-mute "$AUDIO_DEVICE" 1
INITIAL_MUTE_STATUS=$(${WPCTL_CMD_PREFIX}wpctl get-volume "$AUDIO_DEVICE" 2>/dev/null | grep -q "MUTED" && echo "MUTED" || echo "NOT MUTED")
if [ "$INITIAL_MUTE_STATUS" != "MUTED" ]; then
    echo -e "${RED}Warning: Failed to set initial mute state. Current state: $INITIAL_MUTE_STATUS${NC}"
fi

# Using evtest (needs root) and piping its output.
# The wpctl commands inside the loop will use $WPCTL_CMD_PREFIX to run as the user.
evtest "$MOUSE_DEVICE_PATH" | while IFS= read -r line; do
  # Filter for the specific button press and release events
  # Event: time 1747832299.051814, type 1 (EV_KEY), code 275 (BTN_SIDE), value 1
  if echo "$line" | grep -q 'type 1 (EV_KEY).*code 275 (BTN_SIDE).*value 1'; then
    echo -e "${GREEN}BTN_SIDE pressed. Unmuting microphone (ID: $AUDIO_DEVICE)...${NC}"
    ${WPCTL_CMD_PREFIX}wpctl set-mute "$AUDIO_DEVICE" 0
  elif echo "$line" | grep -q 'type 1 (EV_KEY).*code 275 (BTN_SIDE).*value 0'; then
    echo -e "${RED}BTN_SIDE released. Muting microphone (ID: $AUDIO_DEVICE)...${NC}"
    ${WPCTL_CMD_PREFIX}wpctl set-mute "$AUDIO_DEVICE" 1
  fi
done