#!/bin/bash

# Setup script for Backblaze B2 backup with restic
# This script helps configure Backblaze B2 credentials for restic backup

set -e

SECRETS_DIR="/home/user/git/github/monorepo/secrets/environments/personal"
B2_ACCESS_KEY_FILE="$SECRETS_DIR/.b2-access-key"
B2_SECRET_KEY_FILE="$SECRETS_DIR/.b2-secret-key"
RESTIC_PASSWORD_FILE="$SECRETS_DIR/.restic-password"

echo "=== Backblaze B2 Backup Setup ==="
echo ""

# Check if secrets directory exists
if [ ! -d "$SECRETS_DIR" ]; then
    echo "Error: Secrets directory does not exist: $SECRETS_DIR"
    exit 1
fi

echo "Setting up Backblaze B2 credentials for restic backup..."
echo ""

# Function to securely read input
read_secret() {
    local prompt="$1"
    local var_name="$2"
    echo -n "$prompt: "
    read -s value
    echo ""
    eval "$var_name='$value'"
}

# Get Backblaze B2 credentials
echo "Please provide your Backblaze B2 credentials:"
echo "(You can find these in your Backblaze B2 account under 'App Keys')"
echo ""

read_secret "Backblaze B2 Key ID (Application Key ID)" B2_KEY_ID
read_secret "Backblaze B2 Application Key" B2_APP_KEY

# Get restic repository password
echo ""
echo "Please provide a password for your restic repository:"
echo "(This will be used to encrypt your backups - keep it safe!)"
read_secret "Restic repository password" RESTIC_PASSWORD

# Confirm restic password
read_secret "Confirm restic repository password" RESTIC_PASSWORD_CONFIRM

if [ "$RESTIC_PASSWORD" != "$RESTIC_PASSWORD_CONFIRM" ]; then
    echo "Error: Passwords do not match!"
    exit 1
fi

echo ""
echo "Writing credentials to files..."

# Write credentials to files
echo "$B2_KEY_ID" > "$B2_ACCESS_KEY_FILE"
echo "$B2_APP_KEY" > "$B2_SECRET_KEY_FILE"
echo "$RESTIC_PASSWORD" > "$RESTIC_PASSWORD_FILE"

# Set secure permissions
chmod 600 "$B2_ACCESS_KEY_FILE"
chmod 600 "$B2_SECRET_KEY_FILE"
chmod 600 "$RESTIC_PASSWORD_FILE"

echo "✓ Backblaze B2 credentials saved to:"
echo "  - $B2_ACCESS_KEY_FILE"
echo "  - $B2_SECRET_KEY_FILE"
echo "  - $RESTIC_PASSWORD_FILE"
echo ""

# Get bucket information
echo "Please provide your Backblaze B2 bucket information:"
read -p "Bucket name: " BUCKET_NAME
read -p "Backblaze B2 region (e.g., us-west-004): " B2_REGION

echo ""
echo "=== Configuration Summary ==="
echo "Bucket: $BUCKET_NAME"
echo "Region: $B2_REGION"
echo "S3 Endpoint: s3.$B2_REGION.backblazeb2.com"
echo ""

# Show next steps
echo "=== Next Steps ==="
echo "1. Update your host configuration to use the new Backblaze B2 settings:"
echo ""
echo "   modules.tools.restic = {"
echo "     enable = true;"
echo "     bucketName = \"$BUCKET_NAME\";"
echo "     s3Endpoint = \"s3.$B2_REGION.backblazeb2.com\";"
echo "     hostSubdir = \"$(hostname)\";"
echo "     paths = [ \"/home/user\" ];"
echo "   };"
echo ""
echo "2. Rebuild your NixOS configuration:"
echo "   sudo nixos-rebuild switch"
echo ""
echo "3. Test the backup:"
echo "   sudo systemctl start restic-backup"
echo ""
echo "4. Check backup status:"
echo "   sudo systemctl status restic-backup"
echo "   sudo journalctl -u restic-backup -f"
echo ""
echo "5. Enable automatic backups (if not already enabled):"
echo "   sudo systemctl enable restic-backup.timer"
echo "   sudo systemctl start restic-backup.timer"
echo ""

echo "Setup complete! Your Backblaze B2 backup is ready to configure."