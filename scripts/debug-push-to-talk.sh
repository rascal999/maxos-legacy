#!/usr/bin/env bash

# debug-push-to-talk.sh - Script to debug push-to-talk functionality with keyd
# Author: Roo
# Date: 2025-05-21

set -e
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Audio device to control
AUDIO_DEVICE="94" # Jabra EVOLVE 20 MS Mono (ID from wpctl status)

echo -e "${BLUE}=== Push-to-Talk Debugging Script ===${NC}"
echo "This script will help diagnose issues with the push-to-talk functionality."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run this script as root (sudo).${NC}"
  exit 1
fi

# Step 1: Check if keyd is installed
echo -e "\n${YELLOW}Step 1: Checking if keyd is installed...${NC}"
if command -v keyd &> /dev/null; then
  echo -e "${GREEN}✓ keyd is installed.${NC}"
  KEYD_PATH=$(which keyd)
  echo "   Path: $KEYD_PATH"
  KEYD_VERSION=$(keyd --version 2>&1 || echo "Version info not available")
  echo "   Version: $KEYD_VERSION"
else
  echo -e "${RED}✗ keyd is not installed.${NC}"
  echo "   Please install keyd using: nix-env -iA nixos.keyd"
  exit 1
fi

# Step 2: Check if keyd service is running
echo -e "\n${YELLOW}Step 2: Checking if keyd service is running...${NC}"
if systemctl is-active --quiet keyd; then
  echo -e "${GREEN}✓ keyd service is running.${NC}"
  echo "   Status: $(systemctl status keyd | grep "Active:" | sed 's/^[ \t]*//')"
else
  echo -e "${RED}✗ keyd service is not running.${NC}"
  echo "   Attempting to start keyd service..."
  systemctl start keyd
  if systemctl is-active --quiet keyd; then
    echo -e "${GREEN}✓ Successfully started keyd service.${NC}"
  else
    echo -e "${RED}✗ Failed to start keyd service.${NC}"
    echo "   Check logs with: journalctl -u keyd"
  fi
fi

# Step 3: Check keyd configuration
echo -e "\n${YELLOW}Step 3: Checking keyd configuration...${NC}"
if [ -f /etc/keyd/default.conf ]; then
  echo -e "${GREEN}✓ keyd configuration file exists.${NC}"
  echo "   Configuration file: /etc/keyd/default.conf"
  echo "   Content:"
  echo "   --------"
  cat /etc/keyd/default.conf | sed 's/^/   /'
  echo "   --------"
  
  # Check if BTN_SIDE is configured
  if grep -q "BTN_SIDE" /etc/keyd/default.conf; then
    echo -e "${GREEN}✓ BTN_SIDE button is configured.${NC}"
  else
    echo -e "${RED}✗ BTN_SIDE button is not configured in keyd config.${NC}"
    echo "   Please check your configuration."
  fi
else
  echo -e "${RED}✗ keyd configuration file not found.${NC}"
  echo "   Creating a basic configuration file..."
  mkdir -p /etc/keyd
  cat > /etc/keyd/default.conf << EOF
[ids]
046d:*

[main]
BTN_SIDE = macro(exec('wpctl set-mute ${AUDIO_DEVICE} 0') P release exec('wpctl set-mute ${AUDIO_DEVICE} 1'))
EOF
  echo -e "${GREEN}✓ Created basic configuration file.${NC}"
  echo "   Restarting keyd service..."
  systemctl restart keyd
fi

# Step 4: Check audio device
echo -e "\n${YELLOW}Step 4: Checking audio device (attempting as user if sudo)...${NC}"
SUDO_USER_CMD=""
USER_TO_RUN_AS="root" # Default to root

if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
  USER_TO_RUN_AS="$SUDO_USER"
  USER_UID=$(id -u "$SUDO_USER")
  if [ -n "$USER_UID" ]; then
    SUDO_USER_CMD="sudo -u $SUDO_USER XDG_RUNTIME_DIR=/run/user/$USER_UID DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_UID/bus "
    echo -e "   Attempting to run wpctl as user: ${GREEN}$SUDO_USER (UID: $USER_UID)${NC}"
    echo -e "   Setting XDG_RUNTIME_DIR=/run/user/$USER_UID"
    echo -e "   Command prefix: ${YELLOW}${SUDO_USER_CMD}${NC}"
  else
    echo -e "${RED}✗ Could not determine UID for user $SUDO_USER. Will run wpctl as root.${NC}"
    USER_TO_RUN_AS="root"
    SUDO_USER_CMD=""
  fi
else
  echo -e "   Running wpctl as ${GREEN}root${NC} (SUDO_USER not set or is root)."
fi

echo -e "   Executing: ${SUDO_USER_CMD}wpctl status (errors will be shown)"
AUDIO_DEVICES_OUTPUT=$(${SUDO_USER_CMD}wpctl status) # Removed 2>/dev/null
WPCTL_STATUS_EXIT_CODE=$?
echo -e "   wpctl status exit code: $WPCTL_STATUS_EXIT_CODE"

if [ $WPCTL_STATUS_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}✗ Command '${SUDO_USER_CMD}wpctl status' failed with exit code $WPCTL_STATUS_EXIT_CODE.${NC}"
    if [ "$USER_TO_RUN_AS" != "root" ]; then
        echo -e "   Falling back to running wpctl as root..."
        AUDIO_DEVICES_OUTPUT=$(wpctl status)
        WPCTL_STATUS_EXIT_CODE=$?
        echo -e "   wpctl status (as root) exit code: $WPCTL_STATUS_EXIT_CODE"
        if [ $WPCTL_STATUS_EXIT_CODE -ne 0 ]; then
            echo -e "${RED}✗ Command 'wpctl status' (as root) also failed.${NC}"
        fi
    fi
fi

AUDIO_DEVICES=$(echo "$AUDIO_DEVICES_OUTPUT" | grep -A 20 "Audio" | grep "Sources:" -A 20)

if [ -z "$AUDIO_DEVICES" ] && [ $WPCTL_STATUS_EXIT_CODE -eq 0 ]; then
    echo -e "${YELLOW}   wpctl status ran successfully but no audio sources found or output was unexpected.${NC}"
    echo -e "   Full output of 'wpctl status':\n$AUDIO_DEVICES_OUTPUT"
elif [ -z "$AUDIO_DEVICES" ]; then
    echo -e "${RED}✗ Could not retrieve audio devices.${NC}"
fi

echo "   Available audio devices (if any):"
echo "   --------"
echo "$AUDIO_DEVICES" | sed 's/^/   /'
echo "   --------"

if echo "$AUDIO_DEVICES" | grep -q "$AUDIO_DEVICE"; then
  echo -e "${GREEN}✓ Target audio device found: ${AUDIO_DEVICE}${NC}"
else
  echo -e "${RED}✗ Target audio device not found: ${AUDIO_DEVICE}${NC}"
  echo "   Please check the device name and update your configuration."
  echo "   Available devices are listed above."
fi

# Step 5: Test wpctl commands (attempting as user if sudo)
echo -e "\n${YELLOW}Step 5: Testing wpctl commands (attempting as user if sudo)...${NC}"
echo "   Using command prefix for user: [${SUDO_USER_CMD}]"

echo "   Testing mute command..."
${SUDO_USER_CMD}wpctl set-mute "$AUDIO_DEVICE" 1
MUTE_STATUS=$(${SUDO_USER_CMD}wpctl get-volume "$AUDIO_DEVICE" 2>/dev/null | grep -q "MUTED" && echo "MUTED" || echo "NOT MUTED")
if [[ "$MUTE_STATUS" == "NOT MUTED" && -z "$SUDO_USER_CMD" ]]; then # If failed as root, and no user cmd tried
    MUTE_STATUS=$(wpctl get-volume "$AUDIO_DEVICE" 2>/dev/null | grep -q "MUTED" && echo "MUTED" || echo "NOT MUTED") # try as root
fi
echo "   Status after mute: $MUTE_STATUS"


echo "   Testing unmute command..."
${SUDO_USER_CMD}wpctl set-mute "$AUDIO_DEVICE" 0
MUTE_STATUS=$(${SUDO_USER_CMD}wpctl get-volume "$AUDIO_DEVICE" 2>/dev/null | grep -q "MUTED" && echo "MUTED" || echo "NOT MUTED")
if [[ "$MUTE_STATUS" == "NOT MUTED" && -z "$SUDO_USER_CMD" ]]; then # If failed as root, and no user cmd tried
    MUTE_STATUS=$(wpctl get-volume "$AUDIO_DEVICE" 2>/dev/null | grep -q "MUTED" && echo "MUTED" || echo "NOT MUTED") # try as root
fi
echo "   Status after unmute: $MUTE_STATUS"


# Re-check MUTE_STATUS for the final success condition, prioritizing user command result
FINAL_MUTE_CHECK_CMD="${SUDO_USER_CMD}wpctl get-volume \"$AUDIO_DEVICE\""
if ! ${SUDO_USER_CMD}wpctl status &>/dev/null && [ -n "$SUDO_USER_CMD" ]; then # If user command failed to connect, try root for final check
    FINAL_MUTE_CHECK_CMD="wpctl get-volume \"$AUDIO_DEVICE\""
fi

# Perform the unmute one last time before checking
${SUDO_USER_CMD}wpctl set-mute "$AUDIO_DEVICE" 0


FINAL_STATUS=$($FINAL_MUTE_CHECK_CMD 2>/dev/null | grep -q "MUTED" && echo "MUTED" || echo "NOT MUTED")

if [ "$FINAL_STATUS" = "NOT MUTED" ]; then
  echo -e "${GREEN}✓ wpctl commands are working correctly.${NC}"
else
  echo -e "${RED}✗ wpctl commands are not working as expected.${NC}"
  echo "   Please check if the device supports mute control."
fi

# Step 6: Test mouse button events
echo -e "\n${YELLOW}Step 6: Testing mouse button events...${NC}"
echo "   Please press the side button on your mouse now."
echo "   Press Ctrl+C to stop monitoring."
echo "   --------"
echo "   Starting keyd-monitor. Look for BTN_SIDE events:"
KEYD_MONITOR_CMD="keyd-monitor" # Default to just the command name
FOUND_KEYD_MONITOR=false

if [ -n "$KEYD_PATH" ]; then
    # Try common locations relative to keyd daemon or in general Nix store paths
    POSSIBLE_PATHS=(
        "$(dirname "$KEYD_PATH")/keyd-monitor"
        "/run/current-system/sw/bin/keyd-monitor" # Common NixOS path
        # Attempt to find it if the package structure is keyd/bin/keyd-monitor
        "$(dirname "$KEYD_PATH")/../bin/keyd-monitor"
        "$(dirname "$KEYD_PATH")/../libexec/keyd-monitor" # Another common place for helper tools
    )
    for path_attempt in "${POSSIBLE_PATHS[@]}"; do
        if [ -x "$path_attempt" ]; then
            KEYD_MONITOR_CMD="$path_attempt"
            echo "   Using keyd-monitor found at: $KEYD_MONITOR_CMD"
            FOUND_KEYD_MONITOR=true
            break
        fi
    done
fi

if [ "$FOUND_KEYD_MONITOR" = true ]; then
    $KEYD_MONITOR_CMD
elif command -v keyd-monitor &>/dev/null; then
    # Fallback to checking PATH if not found via specific paths
    KEYD_MONITOR_CMD=$(which keyd-monitor)
    echo "   keyd-monitor found in PATH at: $KEYD_MONITOR_CMD. Running it."
    $KEYD_MONITOR_CMD
else
    echo -e "${RED}✗ keyd-monitor command not found directly, in common Nix paths, or in PATH.${NC}"
    echo "   You might need to find its location manually (e.g., with 'nix-locate bin/keyd-monitor' if nix-index is set up)."
    echo "   Skipping direct keyd-monitor test. Please check 'journalctl -u keyd -f' instead while pressing the button."
fi

# This part won't be reached due to keyd-monitor running until Ctrl+C

# Step 7: Manual test
echo -e "\n${YELLOW}Step 7: Manual testing...${NC}"
echo "   Let's create a simple script to toggle the microphone manually."

cat > /tmp/toggle-mic.sh << EOF
#!/bin/bash
# Toggle microphone mute state
DEVICE="${AUDIO_DEVICE}"
CURRENT_STATE=\$(wpctl get-volume "\$DEVICE" | grep -q "MUTED" && echo "MUTED" || echo "NOT MUTED")

if [ "\$CURRENT_STATE" = "MUTED" ]; then
  echo "Unmuting microphone..."
  wpctl set-mute "\$DEVICE" 0
else
  echo "Muting microphone..."
  wpctl set-mute "\$DEVICE" 1
fi

# Show new state
NEW_STATE=\$(wpctl get-volume "\$DEVICE" | grep -q "MUTED" && echo "MUTED" || echo "NOT MUTED")
echo "Microphone is now: \$NEW_STATE"
EOF

chmod +x /tmp/toggle-mic.sh
echo -e "${GREEN}✓ Created toggle script at /tmp/toggle-mic.sh${NC}"
echo "   You can test it by running: /tmp/toggle-mic.sh"

# Step 8: Alternative approach
echo -e "\n${YELLOW}Step 8: Alternative approach - direct input monitoring${NC}"
echo "   If keyd is not working, you can try monitoring input events directly."
echo "   Run the following command to find your mouse device:"
echo "   ls -l /dev/input/by-id/ | grep -i logitech"
echo ""
echo "   Then run evtest on the device and create a simple daemon script."
echo "   Example:"
echo "   sudo evtest /dev/input/eventX | grep -E 'BTN_SIDE.*value 1|BTN_SIDE.*value 0' | while read line; do"
echo "     if echo \"\$line\" | grep -q \"value 1\"; then"
echo "       wpctl set-mute ${AUDIO_DEVICE} 0"
echo "     elif echo \"\$line\" | grep -q \"value 0\"; then"
echo "       wpctl set-mute ${AUDIO_DEVICE} 1"
echo "     fi"
echo "   done"

echo -e "\n${BLUE}=== Debugging Complete ===${NC}"
echo "If you're still having issues, please check the logs with:"
echo "journalctl -u keyd"
echo ""
echo "You can also try creating a direct event monitoring script as described in Step 8."