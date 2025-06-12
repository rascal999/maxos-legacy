#!/bin/sh

# Script to start the WhatsApp bridge service
# This can be used to manually start the service if needed

set -e

WHATSAPP_DIR="/home/user/git/github/whatsapp-mcp"
DATA_DIR="${WHATSAPP_DIR}/data"
BRIDGE_DIR="${WHATSAPP_DIR}/whatsapp-bridge"

# Create data directories if they don't exist
mkdir -p "${DATA_DIR}/store"

# Change to the bridge directory
cd "${BRIDGE_DIR}"

# Start the bridge
echo "Starting WhatsApp bridge..."
go run main.go

# Note: The first time you run this, you will need to scan a QR code with your
# WhatsApp mobile app to authenticate. After approximately 20 days, you might
# need to re-authenticate.