#!/usr/bin/env bash

# Script to start the Stacey Assistant.
# This script navigates to the Stacey assistant's directory and launches it
# within a nix-shell, using a pre-defined audio input device index.

# Define the target directory for the Stacey assistant
# Using absolute path based on user feedback to ensure correctness
# when the script is run from a different location (e.g., ~/.local/bin by home-manager)
STACEY_DIR="/home/user/git/github/monorepo/test_bed/stacey"
DEVICE_NAME_TO_FIND="Jabra EVOLVE 20 MS: USB Audio"

# Check if the Stacey directory exists
if [ ! -d "$STACEY_DIR" ]; then
  echo "Error: Stacey directory not found at $STACEY_DIR"
  # Removed lines that referred to SCRIPT_DIR and MONOREPO_ROOT for this check,
  # as STACEY_DIR is now absolute.
  exit 1
fi

echo "Navigating to Stacey directory: $STACEY_DIR"
cd "$STACEY_DIR" || { echo "Error: Failed to change directory to $STACEY_DIR"; exit 1; }

echo "Current directory: $(pwd)"
echo "Attempting to find audio device index for: '$DEVICE_NAME_TO_FIND'..."

# Command to list devices within the nix-shell environment
LIST_DEVICES_CMD="python stacey_assistant.py --list-devices"

# Run the command and capture its output (stdout and stderr).
# This might take a moment if nix-shell needs to build/fetch dependencies.
echo "Listing audio devices (this may take a moment)..."
DEVICE_LIST_OUTPUT=$(nix-shell shell.nix --extra-experimental-features flakes --run "$LIST_DEVICES_CMD" 2>&1)

# Check if the command to list devices produced any output
if [ -z "$DEVICE_LIST_OUTPUT" ]; then
    echo "Error: Failed to get device list. 'nix-shell ... --list-devices' produced no output."
    exit 1
fi

# Parse the output to find the index for the desired device
# We grep for the device name (fixed string), then use awk to get the first field (the index)
AUDIO_DEVICE_INDEX=$(echo "$DEVICE_LIST_OUTPUT" | grep -F "$DEVICE_NAME_TO_FIND" | awk '{print $1}')

if [ -z "$AUDIO_DEVICE_INDEX" ]; then
  echo "Error: Audio device named '$DEVICE_NAME_TO_FIND' not found."
  echo "-------------------- Full Device List Output --------------------"
  echo "$DEVICE_LIST_OUTPUT"
  echo "-----------------------------------------------------------------"
  exit 1
else
  # Validate if AUDIO_DEVICE_INDEX is a number
  if ! [[ "$AUDIO_DEVICE_INDEX" =~ ^[0-9]+$ ]]; then
    echo "Error: Extracted device index '$AUDIO_DEVICE_INDEX' is not a valid number."
    echo "This might indicate a parsing issue or a change in the device list format."
    echo "-------------------- Full Device List Output --------------------"
    echo "$DEVICE_LIST_OUTPUT"
    echo "-----------------------------------------------------------------"
    exit 1
  fi
  echo "Found audio device index: $AUDIO_DEVICE_INDEX for '$DEVICE_NAME_TO_FIND'"
fi

echo "Starting Stacey Assistant using audio device index ${AUDIO_DEVICE_INDEX}..."

# Execute the nix-shell command, running the python script inside it with the found index.
# Note: The user's original command included --auto-period, so I'm keeping it.
ASSISTANT_CMD="python stacey_assistant.py --auto-period -i ${AUDIO_DEVICE_INDEX}"
nix-shell shell.nix --extra-experimental-features flakes --run "$ASSISTANT_CMD"

echo "Stacey Assistant script finished."