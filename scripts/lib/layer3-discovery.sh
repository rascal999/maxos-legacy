#!/usr/bin/env bash

# Layer 3: Discovery Layer
# Discover system hardware and existing configurations

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Layer 3 execution function
execute_layer3_discovery() {
    log_info "=== LAYER 3: Discovery Layer ==="
    log_info "Discovering system hardware and configurations..."
    
    # Discover available disks and existing LUKS partitions
    discover_disks
    
    # Show available MaxOS profiles
    discover_profiles
    
    # Detect existing installation status
    detect_existing_installation
    
    log_success "Layer 3 (Discovery) completed successfully"
    return 0
}

# Discover available disks and existing LUKS partitions
discover_disks() {
    log_info "Discovering available disks..."
    
    # Show available disks
    log_info "Available disks on remote system:"
    echo "=================================="
    ssh_exec "lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk"
    echo
    
    # Check for existing LUKS partitions
    if check_disk_setup; then
        log_info "Existing LUKS encryption detected"
        
        # Find the disk that contains LUKS partitions
        local luks_partition
        luks_partition=$(ssh_exec "sudo blkid -t TYPE=crypto_LUKS -o device | head -1")
        if [[ -n "$luks_partition" ]]; then
            # Extract base disk name from partition
            if [[ "$luks_partition" =~ ^/dev/nvme ]]; then
                TARGET_DISK=$(echo "$luks_partition" | sed 's/p[0-9]*$//')
            else
                TARGET_DISK=$(echo "$luks_partition" | sed 's/[0-9]*$//')
            fi
            
            log_info "Detected existing LUKS disk: $TARGET_DISK (LUKS partition: $luks_partition)"
            
            # Open LUKS partition if needed for discovery
            if ! ssh_exec "sudo cryptsetup status cryptroot >/dev/null 2>&1"; then
                log_info "LUKS partition needs to be opened for discovery..."
                ssh_exec -t "sudo cryptsetup open $luks_partition cryptroot"
                log_success "LUKS partition opened"
            else
                log_success "LUKS partition already open"
            fi
        fi
    else
        log_info "No existing LUKS encryption found"
    fi
}

# Show available NixOS profiles
discover_profiles() {
    log_info "Discovering available MaxOS profiles..."
    
    local profile_list
    profile_list=$(ssh_exec "cd /tmp/monorepo/maxos && ls hosts/")
    local profiles=($profile_list)
    
    log_info "Available MaxOS profiles:"
    echo "========================="
    for i in "${!profiles[@]}"; do
        echo "$((i+1)). ${profiles[i]}"
    done
    echo
}

# Detect existing installation status
detect_existing_installation() {
    log_info "Detecting existing installation status..."
    
    if check_disk_setup; then
        # Check if we can mount and inspect existing installation
        ssh_exec "
            sudo mkdir -p /mnt &&
            if sudo mount /dev/mapper/cryptroot /mnt 2>/dev/null; then
                if [[ -f /mnt/etc/nixos/configuration.nix ]]; then
                    echo 'Existing NixOS installation detected'
                    if [[ -f /mnt/etc/nixos/hardware-configuration.nix ]]; then
                        echo 'Hardware configuration found'
                    fi
                    if grep -q 'systemd-boot' /mnt/etc/nixos/configuration.nix 2>/dev/null; then
                        echo 'System configured for systemd-boot'
                    elif grep -q 'grub' /mnt/etc/nixos/configuration.nix 2>/dev/null; then
                        echo 'System configured for GRUB'
                    fi
                else
                    echo 'Encrypted disk found but no NixOS installation detected'
                fi
                sudo umount /mnt 2>/dev/null || true
            else
                echo 'Could not mount encrypted disk for inspection'
            fi
        "
    else
        log_info "No existing installation detected"
    fi
}

# Interactive profile selection (used by other layers)
select_profile() {
    local profile_list
    profile_list=$(ssh_exec "cd /tmp/monorepo/maxos && ls hosts/")
    local profiles=($profile_list)
    
    echo "Available MaxOS profiles:"
    for i in "${!profiles[@]}"; do
        echo "$((i+1)). ${profiles[i]}"
    done
    echo
    
    while true; do
        read -p "Choose profile number (1-${#profiles[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#profiles[@]}" ]; then
            NIXOS_PROFILE="${profiles[$((choice-1))]}"
            break
        else
            log_error "Invalid choice. Please enter a number between 1 and ${#profiles[@]}"
        fi
    done
    
    log_success "Selected profile: $NIXOS_PROFILE"
}