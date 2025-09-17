#!/usr/bin/env bash

# Layer 7: Finalization Layer
# Commit changes and prepare for reboot

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Layer 7 execution function
execute_layer7_finalization() {
    log_info "=== LAYER 7: Finalization Layer ==="
    log_info "Committing changes and preparing for reboot..."
    
    # Commit UUID changes to repository
    commit_uuid_changes
    
    # Cleanup temporary mounts
    cleanup_mounts
    
    # Optionally reboot system
    if [[ "${AUTO_REBOOT:-false}" == "true" ]]; then
        reboot_system
    else
        log_info "System ready for manual reboot"
    fi
    
    log_success "Layer 7 (Finalization) completed successfully"
    return 0
}

# Cleanup temporary mounts
cleanup_mounts() {
    log_info "Cleaning up temporary mounts..."
    
    ssh_exec "
        # Unmount any temporary mounts
        sudo umount /mnt/boot 2>/dev/null || true &&
        sudo umount /mnt 2>/dev/null || true &&
        sudo umount /mnt2 2>/dev/null || true &&
        
        # Remove temporary mount points
        sudo rmdir /mnt2 2>/dev/null || true &&
        
        echo 'Cleanup completed'
    "
    
    log_success "Temporary mounts cleaned up"
}

# Reboot remote system
reboot_system() {
    log_info "Installation complete. Rebooting remote system..."
    
    ssh_exec "sudo reboot" || true
    
    log_success "Remote system is rebooting"
    log_info "You will need to enter the LUKS passphrase during boot"
}

# Display final status and instructions
display_final_status() {
    echo
    echo "=========================================="
    log_success "MaxOS installation/configuration completed!"
    echo "=========================================="
    echo
    
    if [[ -n "$NIXOS_PROFILE" ]]; then
        log_info "Profile: $NIXOS_PROFILE"
    fi
    
    if [[ -n "$TARGET_DISK" ]]; then
        log_info "Target disk: $TARGET_DISK"
    fi
    
    echo
    log_info "Next steps:"
    echo "1. Reboot the system"
    echo "2. Enter LUKS passphrase when prompted"
    echo "3. System should boot into MaxOS with correct configuration"
    echo
    
    if [[ "${BOOT_ONLY:-false}" == "true" ]]; then
        log_info "Boot-only mode completed - system configuration updated"
        log_info "The system should now boot correctly with the updated UUIDs"
    else
        log_info "Full installation completed"
        log_info "MaxOS is now installed and ready for use"
    fi
    
    echo "=========================================="
}

# Emergency cleanup function
emergency_cleanup() {
    log_warning "Performing emergency cleanup..."
    
    ssh_exec "
        # Force unmount everything
        sudo umount -f /mnt/boot 2>/dev/null || true &&
        sudo umount -f /mnt 2>/dev/null || true &&
        sudo umount -f /mnt2 2>/dev/null || true &&
        
        # Close LUKS if needed
        sudo cryptsetup close cryptroot 2>/dev/null || true &&
        
        echo 'Emergency cleanup completed'
    " || true
    
    log_warning "Emergency cleanup completed"
}