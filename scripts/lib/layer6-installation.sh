#!/usr/bin/env bash

# Layer 6: Installation Layer
# Install or rebuild the system

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/boot-config.sh"

# Layer 6 execution function
execute_layer6_installation() {
    log_info "=== LAYER 6: Installation Layer ==="
    log_info "Installing or rebuilding the system..."
    
    # Rebuild system using nixos-enter (for boot-only mode)
    rebuild_system_chroot
    
    # Verify installation
    verify_installation
    
    log_success "Layer 6 (Installation) completed successfully"
    return 0
}

# Install NixOS with chosen profile (for full installs)
install_nixos() {
    log_info "Installing NixOS with $NIXOS_PROFILE profile on remote system..."
    
    ssh_exec -t "
        cd /tmp/monorepo/maxos &&
        sudo nixos-install --flake '.#$NIXOS_PROFILE' --root /mnt
    "
    
    log_success "NixOS installation completed"
}

# Verify installation success
verify_installation() {
    log_info "Verifying installation..."
    
    # Check if the system was rebuilt successfully
    ssh_exec "
        # Mount the installed system if not already mounted
        sudo mkdir -p /mnt &&
        sudo mount /dev/mapper/cryptroot /mnt 2>/dev/null || true &&
        sudo mount /dev/nvme1n1p1 /mnt/boot 2>/dev/null || true &&
        
        # Check for systemd-boot installation
        if [[ -d /mnt/boot/EFI/systemd ]]; then
            echo 'systemd-boot EFI entries found'
        elif [[ -d /mnt/boot/EFI/NixOS-boot ]]; then
            echo 'NixOS boot entries found'
        else
            echo 'WARNING: No systemd-boot entries found'
        fi &&
        
        # Check for loader entries
        if [[ -d /mnt/boot/loader/entries ]]; then
            echo 'Boot loader entries found:'
            ls -la /mnt/boot/loader/entries/ 2>/dev/null || echo 'No entries in loader directory'
        else
            echo 'No loader entries directory found'
        fi &&
        
        # Check current system generation
        if [[ -L /mnt/nix/var/nix/profiles/system ]]; then
            echo 'System profile found'
            ls -la /mnt/nix/var/nix/profiles/system* 2>/dev/null | tail -3
        else
            echo 'No system profile found'
        fi
    "
    
    log_success "Installation verification completed"
}

# Check if rebuild was successful
check_rebuild_success() {
    log_info "Checking rebuild success..."
    
    # Look for signs of successful rebuild
    if ssh_exec "
        # Check if systemd-boot was installed
        sudo mount /dev/mapper/cryptroot /mnt 2>/dev/null || true &&
        sudo mount /dev/nvme1n1p1 /mnt/boot 2>/dev/null || true &&
        [[ -d /mnt/boot/EFI/systemd ]] || [[ -d /mnt/boot/loader ]]
    "; then
        log_success "Rebuild appears successful - systemd-boot components found"
        return 0
    else
        log_warning "Rebuild may not have completed successfully"
        return 1
    fi
}