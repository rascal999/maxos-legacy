#!/usr/bin/env bash

# Layer 5: Configuration Layer
# Generate and update system configuration

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/boot-config.sh"

# Layer 5 execution function
execute_layer5_configuration() {
    log_info "=== LAYER 5: Configuration Layer ==="
    log_info "Generating and updating system configuration..."
    
    # Update boot configuration with correct UUIDs
    update_boot_config
    
    # Validate configuration
    validate_configuration
    
    log_success "Layer 5 (Configuration) completed successfully"
    return 0
}

# Validate configuration correctness
validate_configuration() {
    log_info "Validating configuration..."
    
    # Check if profile exists
    if ! ssh_exec "[[ -d /tmp/monorepo/maxos/hosts/$NIXOS_PROFILE ]]"; then
        log_error "Profile directory not found: $NIXOS_PROFILE"
        exit 1
    fi
    
    # Check if boot configuration exists
    if ssh_exec "[[ -f /tmp/monorepo/maxos/hosts/$NIXOS_PROFILE/boot.nix ]]"; then
        log_success "Boot configuration found for profile: $NIXOS_PROFILE"
        
        # Validate UUIDs in boot configuration
        ssh_exec "
            cd /tmp/monorepo/maxos &&
            if grep -q '39AD-D3AF' hosts/$NIXOS_PROFILE/boot.nix; then
                echo 'ERROR: Old EFI UUID still present in boot configuration'
                exit 1
            fi &&
            if grep -q '6F2D-6ACC' hosts/$NIXOS_PROFILE/boot.nix; then
                echo 'Correct EFI UUID found in boot configuration'
            fi &&
            if grep -q '6f4fecf6-9f3f-4fac-9248-b216822b302f' hosts/$NIXOS_PROFILE/boot.nix; then
                echo 'Correct LUKS UUID found in boot configuration'
            fi &&
            if grep -q 'a9db45e6-b2b4-4171-978c-73bb324781c5' hosts/$NIXOS_PROFILE/boot.nix; then
                echo 'Correct root UUID found in boot configuration'
            fi
        "
    else
        log_warning "No boot.nix found for profile $NIXOS_PROFILE, will use hardware-configuration.nix"
    fi
    
    # Check flake syntax
    log_info "Validating flake syntax..."
    if ssh_exec "cd /tmp/monorepo/maxos && nix flake check --no-build 2>/dev/null"; then
        log_success "Flake syntax validation passed"
    else
        log_warning "Flake syntax validation failed, but continuing..."
    fi
    
    log_success "Configuration validation completed"
}

# Generate hardware configuration (for full installs)
generate_hardware_config() {
    if check_hardware_config_generated; then
        log_success "Hardware configuration already generated"
        return 0
    fi
    
    log_info "Generating hardware configuration on remote system..."
    ssh_exec "
        sudo nixos-generate-config --root /mnt &&
        echo 'Hardware configuration generated'
    "
    
    log_success "Hardware configuration generated"
}