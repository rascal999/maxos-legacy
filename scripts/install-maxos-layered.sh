#!/usr/bin/env bash

# MaxOS Layered Installation Script
# Uses layered architecture for modular, maintainable installation process

set -euo pipefail

# Script directory and library path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# Source all layer libraries
source "$LIB_DIR/common.sh"
source "$LIB_DIR/layer1-foundation.sh"
source "$LIB_DIR/layer2-repository.sh"
source "$LIB_DIR/layer3-discovery.sh"
source "$LIB_DIR/layer5-configuration.sh"
source "$LIB_DIR/layer6-installation.sh"
source "$LIB_DIR/layer7-finalization.sh"

# Variables
SSH_USER=""
SSH_HOST=""
TARGET_DISK=""
NIXOS_PROFILE=""
DISCOVERY_ONLY=false
AUTO_REBOOT=false

# Show usage
show_usage() {
    cat << EOF
MaxOS Layered Installation Script

This script uses a layered architecture to install MaxOS on a remote NixOS live USB system.

Usage: $0 -u SSH_USER -h SSH_HOST [OPTIONS]

Required Options:
    -u, --user USER         SSH username (e.g., nixos)
    -h, --host HOST         SSH hostname/IP (e.g., 192.168.1.110)

Optional Options:
    --discovery-only        Only discover system information (layers 1-3)
    --auto-reboot           Automatically reboot after installation
    --help                  Show this help message

Execution Modes:
    Full Installation:      All layers 1-7 for complete fresh installation
    Discovery Mode:         Layers 1-3 for system inspection only

Layer Architecture:
    Layer 1: Foundation     - SSH connectivity, Git, GitHub access
    Layer 2: Repository     - Clone MaxOS repository
    Layer 3: Discovery      - Hardware detection, profile selection
    Layer 4: Storage        - LUKS encryption, partitioning (full install only)
    Layer 5: Configuration  - Generate configs, update UUIDs
    Layer 6: Installation   - Install/rebuild system
    Layer 7: Finalization   - Commit changes, cleanup, reboot

Examples:
    $0 -u nixos -h 192.168.1.110                    # Full installation
    $0 -u nixos -h 192.168.1.110 --discovery-only   # Inspect system only

WARNING: Full installation will DESTROY all data on the chosen disk!
NOTE: This script requires SSH key authentication.
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u|--user)
                SSH_USER="$2"
                shift 2
                ;;
            -h|--host)
                SSH_HOST="$2"
                shift 2
                ;;
            --discovery-only)
                DISCOVERY_ONLY=true
                shift
                ;;
            --auto-reboot)
                AUTO_REBOOT=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "$SSH_USER" || -z "$SSH_HOST" ]]; then
        log_error "SSH user and host are required"
        show_usage
        exit 1
    fi
}

# Execute discovery-only mode (layers 1-3)
execute_discovery_mode() {
    echo "MaxOS System Discovery"
    echo "====================="
    echo
    
    log_info "Discovery mode: inspecting system without making changes"
    
    # Execute discovery layers only
    execute_layer1_foundation
    execute_layer2_repository
    execute_layer3_discovery
    
    log_success "Discovery completed - no changes made to system"
}

# Execute full installation mode (all layers)
execute_full_installation() {
    echo "MaxOS Full Installation"
    echo "======================="
    echo
    
    log_info "Full installation mode: complete MaxOS installation"
    
    # Execute all layers
    execute_layer1_foundation
    execute_layer2_repository
    execute_layer3_discovery
    
    # Interactive profile selection
    select_profile
    
    # TODO: Add Layer 4 (Storage) for full installations
    log_warning "Layer 4 (Storage) not yet implemented - using existing LUKS setup"
    
    execute_layer5_configuration
    execute_layer6_installation
    execute_layer7_finalization
    
    display_final_status
}

# Main execution function
main() {
    echo "MaxOS Layered Installation Script"
    echo "================================="
    echo
    
    # Parse arguments
    parse_args "$@"
    
    # Set up error handling
    trap 'emergency_cleanup; exit 1' ERR
    
    # Execute based on mode
    if [[ "$DISCOVERY_ONLY" == "true" ]]; then
        execute_discovery_mode
    else
        execute_full_installation
    fi
    
    log_success "Script execution completed successfully"
}

# Show help if no arguments provided
if [[ $# -eq 0 ]]; then
    show_usage
    exit 0
fi

# Run main function
main "$@"