#!/usr/bin/env bash

# Exit on error
set -e

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Check if disk parameter is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <disk-device>"
    echo "Example: $0 /dev/nvme0n1"
    exit 1
fi

DISK="$1"

# Check if disk exists
if [ ! -b "$DISK" ]; then
    echo "Error: Disk $DISK not found"
    exit 1
fi

# Warning message
echo "WARNING: This will ERASE ALL DATA on $DISK"
echo "The script will:"
echo "1. Create GPT partition table"
echo "2. Create EFI boot partition (512MB)"
echo "3. Create LUKS encrypted root partition (rest of disk)"
echo
echo "Are you sure you want to continue? (yes/no)"
read -r confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted"
    exit 1
fi

echo "Starting disk setup..."

# Unmount any mounted partitions from this disk
echo "Unmounting any mounted partitions..."
umount "${DISK}"* 2>/dev/null || true
umount /mnt/boot 2>/dev/null || true
umount /mnt 2>/dev/null || true

# Close any open LUKS containers
echo "Closing any open LUKS containers..."
cryptsetup close cryptroot 2>/dev/null || true

# Force kernel to re-read partition table
echo "Forcing kernel to re-read partition table..."
partprobe "$DISK" 2>/dev/null || true
sleep 2

# Create GPT partition table
echo "Creating GPT partition table..."
parted "$DISK" mklabel gpt

# Create EFI partition
echo "Creating EFI partition..."
parted "$DISK" mkpart ESP fat32 1MiB 512MiB
parted "$DISK" set 1 esp on

# Create root partition
echo "Creating root partition..."
parted "$DISK" mkpart primary 512MiB 100%

# Get partition names
if [[ "$DISK" =~ ^/dev/nvme ]]; then
    # NVMe drives use 'p' prefix for partition numbers
    EFI_PART="${DISK}p1"
    ROOT_PART="${DISK}p2"
else
    # SATA drives use direct numbers
    EFI_PART="${DISK}1"
    ROOT_PART="${DISK}2"
fi

# Format EFI partition
echo "Formatting EFI partition..."
mkfs.fat -F 32 "$EFI_PART"

# Setup LUKS encryption
echo "Setting up LUKS encryption..."
echo "Enter passphrase for LUKS encryption:"
cryptsetup luksFormat "$ROOT_PART"

# Open LUKS container
echo "Opening LUKS container..."
echo "Enter passphrase to open LUKS container:"
cryptsetup open "$ROOT_PART" cryptroot

# Format root partition
echo "Formatting root partition..."
mkfs.ext4 /dev/mapper/cryptroot

echo "Done! Your disk is now set up with LUKS encryption."
echo
echo "Device information for NixOS configuration:"
echo "EFI partition: $EFI_PART"
echo "LUKS partition: $ROOT_PART"
echo
echo "Next steps:"
echo "1. Mount partitions:"
echo "   mount /dev/mapper/cryptroot /mnt"
echo "   mkdir -p /mnt/boot"
echo "   mount $EFI_PART /mnt/boot"
echo
echo "2. Generate NixOS configuration:"
echo "   nixos-generate-config --root /mnt"
echo
echo "3. Update hardware configuration with LUKS details:"
echo "   boot.initrd.luks.devices.cryptroot.device = \"$ROOT_PART\";"
