#!/usr/bin/env bash

# MaxOS Boot Configuration Library
# Functions for managing boot configuration and UUID updates

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Update boot configuration with correct UUIDs
update_boot_config() {
    log_info "Updating boot configuration with correct UUIDs..."
    
    # Get the actual disk device from cryptroot mapping if TARGET_DISK is not properly set
    if [[ -z "$TARGET_DISK" ]] || [[ "$TARGET_DISK" =~ ├─ ]]; then
        local actual_disk
        actual_disk=$(ssh_exec "sudo cryptsetup status cryptroot | grep 'device:' | awk '{print \$2}' | sed 's/p[0-9]*$//'")
        
        if [[ -z "$actual_disk" ]]; then
            log_error "Could not determine disk from cryptroot mapping"
            ssh_exec "sudo cryptsetup status cryptroot || echo 'cryptroot not found'"
            exit 1
        fi
        
        TARGET_DISK="$actual_disk"
        log_info "Detected target disk from cryptroot: $TARGET_DISK"
    fi
    
    # Determine partition names based on disk type
    local efi_part root_part
    if [[ "$TARGET_DISK" =~ ^/dev/nvme ]]; then
        efi_part="${TARGET_DISK}p1"
        root_part="${TARGET_DISK}p2"
    else
        efi_part="${TARGET_DISK}1"
        root_part="${TARGET_DISK}2"
    fi
    
    log_info "Using partitions: EFI=$efi_part, LUKS=$root_part"
    
    # Ensure cryptroot is open to get root UUID
    ssh_exec "sudo cryptsetup open $root_part cryptroot 2>/dev/null || true"
    
    # Get UUIDs using blkid directly - more reliable than parsing lsblk
    local luks_uuid efi_uuid root_uuid
    
    # Get LUKS UUID
    luks_uuid=$(ssh_exec "sudo blkid $root_part -s UUID -o value 2>/dev/null || echo ''")
    
    # Get EFI UUID
    efi_uuid=$(ssh_exec "sudo blkid $efi_part -s UUID -o value 2>/dev/null || echo ''")
    
    # Get root filesystem UUID
    root_uuid=$(ssh_exec "sudo blkid /dev/mapper/cryptroot -s UUID -o value 2>/dev/null || echo ''")
    
    log_info "Detected UUIDs:"
    log_info "  LUKS partition ($root_part): $luks_uuid"
    log_info "  EFI partition ($efi_part): $efi_uuid"
    log_info "  Root partition (/dev/mapper/cryptroot): $root_uuid"
    
    # Validate UUIDs are not empty
    if [[ -z "$luks_uuid" || -z "$efi_uuid" || -z "$root_uuid" ]]; then
        log_error "Failed to detect one or more UUIDs:"
        [[ -z "$luks_uuid" ]] && log_error "  - LUKS UUID missing"
        [[ -z "$efi_uuid" ]] && log_error "  - EFI UUID missing"
        [[ -z "$root_uuid" ]] && log_error "  - Root UUID missing"
        log_error "Debug information:"
        ssh_exec "sudo lsblk -f $TARGET_DISK* /dev/mapper/cryptroot 2>/dev/null || true"
        exit 1
    fi
    
    # Update the boot.nix file with correct UUIDs for the target profile
    ssh_exec "
        cd /tmp/monorepo/maxos &&
        if [[ -f hosts/$NIXOS_PROFILE/boot.nix ]]; then
            cp hosts/$NIXOS_PROFILE/boot.nix hosts/$NIXOS_PROFILE/boot.nix.backup &&
            # Set variables for UUID replacement
            LUKS_UUID='$luks_uuid' &&
            ROOT_UUID='$root_uuid' &&
            EFI_UUID='$efi_uuid' &&
            EFI_PART='$efi_part' &&
            
            echo 'Updating UUIDs in boot configuration:' &&
            echo '  LUKS UUID: '$luks_uuid &&
            echo '  Root UUID: '$root_uuid &&
            echo '  EFI UUID: '$efi_uuid &&
            echo '  EFI Partition: '$efi_part &&
            
            # Update LUKS device UUID (in luks.devices section)
            sed -i \"/luks\.devices/,/};/ s|device = \\\"/dev/disk/by-uuid/[a-fA-F0-9-]*\\\"|device = \\\"/dev/disk/by-uuid/\$LUKS_UUID\\\"|\" hosts/$NIXOS_PROFILE/boot.nix &&
            
            # Update root filesystem UUID (in fileSystems.\"/\" section)
            sed -i \"/fileSystems = {/,/};/ { /\\\"\/\\\" = {/,/};/ s|device = \\\"/dev/disk/by-uuid/[a-fA-F0-9-]*\\\"|device = \\\"/dev/disk/by-uuid/\$ROOT_UUID\\\"|; }\" hosts/$NIXOS_PROFILE/boot.nix &&
            
            # For EFI partition, try UUID first, fallback to device path if UUID format is problematic
            if [[ \$EFI_UUID =~ ^[A-F0-9]{4}-[A-F0-9]{4}$ ]]; then
                echo 'Using EFI UUID (valid FAT32 format): '\$EFI_UUID &&
                sed -i \"/fileSystems = {/,/};/ { /\\\"\/boot\\\" = {/,/};/ s|device = \\\"/dev/[^\\\"]*\\\"|device = \\\"/dev/disk/by-uuid/\$EFI_UUID\\\"|; }\" hosts/$NIXOS_PROFILE/boot.nix
            else
                echo 'EFI UUID format invalid, using device path: '\$EFI_PART &&
                sed -i \"/fileSystems = {/,/};/ { /\\\"\/boot\\\" = {/,/};/ s|device = \\\"/dev/[^\\\"]*\\\"|device = \\\"\$EFI_PART\\\"|; }\" hosts/$NIXOS_PROFILE/boot.nix
            fi &&
            
            echo 'Boot configuration updated successfully for profile: $NIXOS_PROFILE'
        else
            echo 'Warning: No boot.nix found for profile $NIXOS_PROFILE, using hardware-configuration.nix'
        fi
    "
    
    log_success "Boot configuration updated with correct UUIDs"
}

# Rebuild system using nixos-enter
rebuild_system_chroot() {
    log_info "Rebuilding system with updated boot configuration..."
    ssh_exec -t "
        # Mount the installed system
        sudo mkdir -p /mnt &&
        sudo mount /dev/mapper/cryptroot /mnt &&
        sudo mount /dev/nvme1n1p1 /mnt/boot &&
        
        # Copy the updated repository to the installed system
        sudo cp -r /tmp/monorepo /mnt/tmp/ &&
        
        # Use nixos-enter to properly enter the installed system and rebuild
        sudo nixos-enter --root /mnt -- bash -c '
            cd /tmp/monorepo/maxos &&
            nixos-rebuild switch --flake \".#$NIXOS_PROFILE\"
        '
    "
    log_success "System rebuilt with updated configuration"
}