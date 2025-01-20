# Encrypting Existing NixOS Installation

This guide covers encrypting an existing unencrypted NixOS installation.

## Warning

This process involves:
- Complete data backup required
- System reinstallation
- Risk of data loss
- Downtime during migration

## Prerequisites

- Backup all important data
- Bootable NixOS USB (using Ventoy)
- Sufficient free space for backup
- Working internet connection

## Process Overview

Since LUKS encryption must be set up before the filesystem, we need to:
1. Back up existing system
2. Create new encrypted partition
3. Restore data
4. Update configuration

## Step-by-Step Guide

1. Boot into NixOS Live USB

2. Back up existing system:
   ```bash
   # Mount existing root
   sudo mount /dev/sdX2 /mnt  # Replace sdX2 with your root partition

   # Create backup
   cd /mnt
   sudo tar czf /tmp/nixos-backup.tar.gz .
   ```

3. Set up encrypted partition:
   ```bash
   # Make LUKS script executable
   curl -O https://raw.githubusercontent.com/rascal999/monorepo/main/maxos/scripts/setup-luks.sh
   chmod +x setup-luks.sh

   # Run script (use same disk as before)
   sudo ./setup-luks.sh /dev/sdX
   ```

4. Restore system:
   ```bash
   # Your LUKS partition should already be mounted at /mnt
   cd /mnt
   sudo tar xzf /tmp/nixos-backup.tar.gz
   ```

5. Update configuration:
   ```bash
   # Generate hardware config
   sudo nixos-generate-config --root /mnt

   # Edit configuration
   sudo nano /mnt/etc/nixos/hardware-configuration.nix
   ```

   Add LUKS configuration:
   ```nix
   boot.initrd.luks.devices."cryptroot" = {
     device = "/dev/disk/by-uuid/YOUR-UUID";  # Get UUID from blkid
     preLVM = true;
   };
   ```

6. Rebuild and reboot:
   ```bash
   # Rebuild system
   sudo nixos-rebuild boot --install-bootloader

   # Reboot
   sudo reboot
   ```

## Verifying Encryption

After reboot:
1. System should prompt for LUKS password
2. Check partition status:
   ```bash
   lsblk -f  # Should show LUKS partition
   ```

## Troubleshooting

- If boot fails:
  * Check LUKS configuration
  * Verify UUIDs are correct
  * Ensure initrd includes needed modules

- If data is inaccessible:
  * Boot from USB
  * Mount encrypted partition manually
  * Check filesystem integrity

## Recovery

Keep your backup until you've verified:
- System boots correctly
- All data is accessible
- Encryption is working
- Performance is acceptable

## Notes

- Consider using a separate /boot partition
- Keep backup in safe location
- Document any custom configuration
- Test full backup restoration
