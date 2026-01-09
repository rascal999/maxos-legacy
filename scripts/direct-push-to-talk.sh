#!/usr/bin/env bash

# direct-push-to-talk.sh - Direct event monitoring for push-to-talk functionality
# Author: Roo
# Date: 2025-11-21

# This script directly monitors mouse button events and controls the microphone
# without relying on keyd. It's an alternative approach if keyd isn't working.

# Description of the target microphone to control
#TARGET_AUDIO_DESC="Jabra EVOLVE 20 MS Mono" # Exact name of the source device
TARGET_AUDIO_DESC="USB Composite Device"
# This will be dynamically populated
AUDIO_DEVICE=""
# Stable mouse event device path for Logitech USB Receiver
MOUSE_DEVICE_PATH="/dev/input/by-id/usb-Logitech_USB_Receiver-event-mouse"

# Colors for output
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Direct Push-to-Talk Script ===${NC}"
echo -e "This script monitors '${YELLOW}$MOUSE_DEVICE_PATH${NC}' for BTN_SIDE (code 275)."
echo -e "It will control microphone ID '${YELLOW}$AUDIO_DEVICE${NC}'."
echo -e "Run this script with ${GREEN}sudo${NC}." # Note: This line is now informational, service will run as user.

# Root check removed for systemd user service.
# Ensure udev rules grant user access to $MOUSE_DEVICE_PATH.
# Example udev rule for user access (if not already covered):
# KERNEL=="event*", SUBSYSTEM=="input", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c547", MODE="0660", GROUP="input", TAG+="uaccess"
# (The existing KERNEL=="event3", OWNER="user" rule might be sufficient if it targets the device pointed to by the by-id path)

if [ ! -e "$MOUSE_DEVICE_PATH" ]; then
    echo -e "${RED}Error: Mouse device path not found: $MOUSE_DEVICE_PATH${NC}"
    echo -e "Please verify this path. You can list devices with 'ls /dev/input/event*'"
    echo -e "And identify your mouse with 'evtest' (run it and select devices if not run as root, or 'sudo evtest')."
    exit 1
fi

# Determine user context for running wpctl
WPCTL_CMD_PREFIX=""
# Use id from coreutils for robustness, assuming it's in PATH via systemd service env
CURRENT_USER_WHOAMI=$(id -un 2>/dev/null || echo "unknown_user")
CURRENT_USER_ID=$(id -u 2>/dev/null || echo "unknown_id")

if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ] && [ "$SUDO_USER" != "$CURRENT_USER_WHOAMI" ]; then
  # Script is run with sudo by a different user than the one who owns the terminal session.
  # This is the typical manual "sudo ./script.sh" case.
  USER_UID_FOR_WPCTL=$(id -u "$SUDO_USER")
  if [ -n "$USER_UID_FOR_WPCTL" ]; then
    WPCTL_CMD_PREFIX="sudo -u $SUDO_USER XDG_RUNTIME_DIR=/run/user/$USER_UID_FOR_WPCTL DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$USER_UID_FOR_WPCTL/bus "
    echo -e "Manual sudo detected. Running wpctl as original user: ${GREEN}$SUDO_USER (UID: $USER_UID_FOR_WPCTL)${NC}"
  else
    echo -e "${RED}Warning: Could not determine UID for SUDO_USER ($SUDO_USER). wpctl might fail.${NC}"
  fi
elif [ "$EUID" -eq 0 ] && [ -z "$SUDO_USER" ]; then
  # Script is run as root directly (e.g., by a systemd system service).
  # This script is intended for user sessions, so this case is problematic for wpctl.
  # For a systemd *user* service, this branch won't be hit as EUID won't be 0.
  echo -e "${RED}Warning: Script running as root directly. wpctl may not target the correct user session.${NC}"
  echo -e "         This script is best run as a systemd user service or via 'sudo ./script.sh' by a regular user."
  # WPCTL_CMD_PREFIX remains empty, wpctl will run as root.
else
  # Script is running as a regular user (e.g., systemd user service, or direct execution without sudo).
  # WPCTL_CMD_PREFIX remains empty, wpctl will run as this current user.
  echo -e "Running as current user: ${GREEN}$CURRENT_USER_WHOAMI (UID: $CURRENT_USER_ID)${NC}. wpctl will use this user's session."
fi

# Dynamically find the audio device ID using its description
echo -e "${BLUE}Attempting to find audio source ID for: '${YELLOW}$TARGET_AUDIO_DESC${BLUE}'...${NC}"
WPCTL_STATUS_OUTPUT=$(${WPCTL_CMD_PREFIX}wpctl status)
echo -e "${BLUE}--- Full wpctl status output as seen by script: ---${NC}\n${WPCTL_STATUS_OUTPUT}\n${BLUE}--- End of wpctl status output ---${NC}" >&2

read -r -d '' AWK_SCRIPT << 'EOF'
BEGIN {in_sources=0; print "AWK_DEBUG: BEGIN" > "/dev/stderr"}
# Match "Sources:" line, allowing for tree prefixes like "  ├─ Sources:"
/^[[:space:]]*(├─[[:space:]]*)?Sources:/ {
  in_sources=1; print "AWK_DEBUG: Entered Sources section (line: [" $0 "])" > "/dev/stderr"; next
}
# Match "Sinks:" line to reset flag if we pass out of sources, also allowing for tree prefixes
/^[[:space:]]*(├─[[:space:]]*)?Sinks:/ {
  if(in_sources == 1) { # Only print "Left" if we were actually in sources
      in_sources=0; print "AWK_DEBUG: Left Sources section (hit Sinks, line: [" $0 "])" > "/dev/stderr";
  }
  next # Continue to next line, as this is not a source item
}
# If we hit other major section headers like Video or Settings, also assume we're out of Audio Sources
# Note: The regex (Video|Settings...) is safe inside the heredoc for awk.
/^[[:space:]]*(├─|└─)?[[:space:]]*(Video|Settings|Clients|Filters|Streams|Devices):/ {
  if(in_sources == 1) {
      in_sources=0; print "AWK_DEBUG: Left Sources section (hit other section: [" $0 "])" > "/dev/stderr";
  }
  next;
}

!in_sources {next} # Only process lines if we are in the Sources section

# If in sources section and line contains the description:
index($0, desc) {
  print "AWK_DEBUG: Matched description line: [" $0 "]" > "/dev/stderr"
  # Iterate through fields to find the one that looks like "123."
  for (i=1; i<=NF; ++i) {
    print "AWK_DEBUG: Checking field " i ": [" $i "]" > "/dev/stderr"
    if ($i ~ /^[0-9]+\.$/) { # Field is composed of digits followed by a literal dot
      id_val = $i
      sub(/\.$/, "", id_val) # Remove the trailing dot
      print "AWK_DEBUG: Found potential ID: [" id_val "]" > "/dev/stderr"
      print id_val # This is the actual output to be captured by AUDIO_DEVICE
      exit # Exit awk once found
    }
  }
  print "AWK_DEBUG: Did not find ID in fields on matched line: [" $0 "]" > "/dev/stderr"
}
EOF

AUDIO_DEVICE=$(echo "$WPCTL_STATUS_OUTPUT" | awk -v desc="$TARGET_AUDIO_DESC" "$AWK_SCRIPT")

if [ -z "$AUDIO_DEVICE" ]; then
  echo -e "${RED}Error: Could not find audio source matching description: '$TARGET_AUDIO_DESC'${NC}"
  echo -e "${YELLOW}Please check 'wpctl status' output and the TARGET_AUDIO_DESC variable in the script.${NC}"
  exit 1
else
  echo -e "${GREEN}Found audio source '$TARGET_AUDIO_DESC' with ID: $AUDIO_DEVICE${NC}"
fi

echo -e "${GREEN}Monitoring mouse device: $MOUSE_DEVICE_PATH${NC}"
echo -e "${GREEN}Controlling audio device ID: $AUDIO_DEVICE ($TARGET_AUDIO_DESC)${NC}"
echo -e "${YELLOW}Press and hold your designated mouse button. Release to mute.${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop this script.${NC}"

# Function to ensure mic is muted on exit
cleanup() {
    echo -e "\n${BLUE}Cleaning up...${NC}"
    echo "Ensuring microphone is muted..."
    ${WPCTL_CMD_PREFIX}wpctl set-mute "$AUDIO_DEVICE" 1
    echo "Exiting PTT script."
}
trap cleanup EXIT INT TERM

# Ensure microphone is initially muted
echo "Initializing microphone to muted state..."
# Attempt to run wpctl as the logged-in user if sudo is used
echo -e "Initializing microphone to ${RED}MUTED${NC} state..."
${WPCTL_CMD_PREFIX}wpctl set-mute "$AUDIO_DEVICE" 1
INITIAL_MUTE_STATUS=$(${WPCTL_CMD_PREFIX}wpctl get-volume "$AUDIO_DEVICE" 2>/dev/null | grep -q "MUTED" && echo "MUTED" || echo "NOT MUTED")
if [ "$INITIAL_MUTE_STATUS" != "MUTED" ]; then
    echo -e "${RED}Warning: Failed to set initial mute state. Current state: $INITIAL_MUTE_STATUS${NC}"
fi

# Using evsieve to handle events
# Construct the full commands for evsieve exec. Using single quotes around $AUDIO_DEVICE
# to ensure it's passed as a literal string to the subshell evsieve creates.
CMD_UNMUTE_STR="${WPCTL_CMD_PREFIX}wpctl set-mute '$AUDIO_DEVICE' 0"
CMD_MUTE_STR="${WPCTL_CMD_PREFIX}wpctl set-mute '$AUDIO_DEVICE' 1"

echo -e "${BLUE}Starting evsieve to monitor ${YELLOW}$MOUSE_DEVICE_PATH${BLUE}...${NC}"
echo -e "Unmuting with: ${GREEN}${CMD_UNMUTE_STR}${NC}"
echo -e "Muting with:   ${RED}${CMD_MUTE_STR}${NC}"

# evsieve will run in the foreground. Ctrl+C will stop it, and the trap will clean up.
# The @grab suffix tells evsieve to attempt to grab the device.
# BTN_SIDE is key code 275.
evsieve \
  --input "${MOUSE_DEVICE_PATH}" grab \
  --hook "key:%275:1" "exec-shell=${CMD_UNMUTE_STR}" \
  --hook "key:%275:0" "exec-shell=${CMD_MUTE_STR}" \
  --block "key:%275" \
  --output

# If evsieve exits, the script will also exit, and the trap will run.
# An explicit exit might be good if evsieve can exit cleanly on its own.
echo -e "${BLUE}evsieve finished or was interrupted.${NC}"
