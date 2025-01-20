# Installation Guide

This guide covers the installation process for MaxOS on physical hardware.

## Prerequisites

- USB drive (at least 8GB)
- UEFI-capable system
- Internet connection

## Preparing Installation Media

1. Download and install Ventoy:
   - Visit https://www.ventoy.net/en/download.html
   - Download the latest version for your OS
   - Extract and run the Ventoy installation:
     ```bash
     # Example for Linux
     ./VentoyGUI.x86_64
     ```
   - Select your USB device and install Ventoy
   - IMPORTANT: This will erase all data on the USB drive

2. Download NixOS:
   - Visit https://nixos.org/download.html
   - Download the GNOME version
   - Copy the ISO file to your Ventoy USB drive

3. Create a data partition (optional):
   - Use GParted or similar to create a second partition
   - Format as ext4 with label "NIXOS_DATA"
   - This can be used to store the MaxOS configuration

## Installation Steps

1. Boot from USB:
   - Enter BIOS/UEFI settings
   - Set boot priority to USB
   - Save and restart
   - Select NixOS from Ventoy menu

2. Once NixOS boots:
   ```bash
   # Install Git if needed
   nix-env -iA nixos.git

   # Clone MaxOS repository
   git clone https://github.com/rascal999/monorepo.git
   cd monorepo/maxos
   ```

3. Set up disk encryption:
   ```bash
   # Make script executable
   chmod +x scripts/setup-luks.sh

   # Run script (replace sdX with your disk, e.g., nvme0n1, sda)
   sudo ./setup-luks.sh /dev/sdX
   ```

   The script will:
   - Create GPT partition table
   - Set up EFI boot partition
   - Create and configure LUKS encrypted root partition
   - Format partitions
   - Mount everything for installation

4. Deploy MaxOS:
   - Create a new host configuration:
     ```bash
     # Copy desktop template
     cp -r hosts/desktop hosts/your-hostname
     ```
   - Customize configuration:
     - Edit hardware settings
     - Configure network
     - Adjust system options

5. Build and activate:
   ```bash
   # Test build first
   sudo nixos-rebuild build --flake .#your-hostname
   
   # If successful, switch to new configuration
   sudo nixos-rebuild switch --flake .#your-hostname
   ```

## Notes

- Keep your USB drive as a recovery tool
- Store important configuration backups
- Document any hardware-specific changes
- Test system encryption before storing sensitive data

## Encryption

If you installed NixOS without encryption and want to enable it:
- See [Encrypting Existing Installation](encrypt-existing.md)
- This requires system backup and reinstallation
- Plan for downtime during the process
- Follow all backup steps carefully

## Troubleshooting

- If boot fails:
  * Try disabling Secure Boot
  * Use nomodeset boot option
  * Check UEFI/Legacy boot settings
- If encryption setup fails:
  * Verify disk is not in use
  * Check for existing partitions
  * Ensure sufficient disk space
