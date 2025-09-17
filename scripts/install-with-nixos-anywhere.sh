#!/usr/bin/env bash

# MaxOS Installation using nixos-anywhere
# This script uses the industry-standard nixos-anywhere tool for remote NixOS installations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables
SSH_USER=""
SSH_HOST=""
NIXOS_PROFILE=""
SSH_KEY=""
LUKS_PASSWORD=""

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage
show_usage() {
    cat << EOF
MaxOS Installation using nixos-anywhere

This script uses nixos-anywhere for robust remote NixOS installations with LUKS encryption.

Usage: $0 -u SSH_USER -h SSH_HOST -p PROFILE [OPTIONS]

Required Options:
    -u, --user USER         SSH username (e.g., nixos)
    -h, --host HOST         SSH hostname/IP (e.g., 192.168.1.110)
    -p, --profile PROFILE   MaxOS profile to install (e.g., rig, rig-minimal)

Optional Options:
    -i, --identity FILE     SSH private key file (default: ~/.ssh/id_ed25519)
    --help                  Show this help message

Available Profiles:
    rig                     Full MaxOS workstation with comprehensive tools
    rig-minimal             Ultra-minimal console-only system for testing
    G16                     Gaming workstation configuration
    desktop-test-vm         Desktop testing VM configuration

Examples:
    $0 -u nixos -h 192.168.1.110 -p rig-minimal           # Minimal installation
    $0 -u nixos -h 192.168.1.110 -p rig                   # Full workstation
    $0 -u nixos -h 192.168.1.110 -p rig -i ~/.ssh/mykey   # Custom SSH key

Features:
    ✅ LUKS disk encryption with secure password prompt
    ✅ Automatic disk partitioning via disko
    ✅ Robust error handling and rollback
    ✅ Industry-standard nixos-anywhere tool
    ✅ Support for all MaxOS profiles

WARNING: This will DESTROY all data on the target disk!
NOTE: Requires SSH key authentication to target host.
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
            -p|--profile)
                NIXOS_PROFILE="$2"
                shift 2
                ;;
            -i|--identity)
                SSH_KEY="$2"
                shift 2
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
    if [[ -z "$SSH_USER" || -z "$SSH_HOST" || -z "$NIXOS_PROFILE" ]]; then
        log_error "SSH user, host, and profile are required"
        show_usage
        exit 1
    fi
    
    # Set default SSH key if not provided
    if [[ -z "$SSH_KEY" ]]; then
        SSH_KEY="$HOME/.ssh/id_ed25519"
    fi
    
    # Validate SSH key exists
    if [[ ! -f "$SSH_KEY" ]]; then
        log_error "SSH key not found: $SSH_KEY"
        exit 1
    fi
    
    # Validate profile exists
    if [[ ! -d "hosts/$NIXOS_PROFILE" ]]; then
        log_error "Profile not found: $NIXOS_PROFILE"
        log_info "Available profiles:"
        ls hosts/ | sed 's/^/  - /'
        exit 1
    fi
}

# Get LUKS password securely
get_luks_password() {
    echo
    log_warning "LUKS disk encryption setup required"
    echo "You will need to set a password for disk encryption."
    echo "This password will be required every time the system boots."
    echo
    
    while true; do
        read -s -p "Enter LUKS encryption password: " LUKS_PASSWORD
        echo
        read -s -p "Confirm LUKS encryption password: " confirm_password
        echo
        
        if [[ "$LUKS_PASSWORD" == "$confirm_password" ]]; then
            if [[ ${#LUKS_PASSWORD} -lt 8 ]]; then
                log_error "Password must be at least 8 characters long"
                continue
            fi
            break
        else
            log_error "Passwords do not match. Please try again."
        fi
    done
    
    log_success "LUKS password set"
}

# Main installation function
main() {
    echo "MaxOS Installation with nixos-anywhere"
    echo "======================================"
    echo
    
    # Parse arguments
    parse_args "$@"
    
    # Display configuration
    log_info "Installation Configuration:"
    echo "  Target: $SSH_USER@$SSH_HOST"
    echo "  Profile: $NIXOS_PROFILE"
    echo "  SSH Key: $SSH_KEY"
    echo
    
    # Get LUKS password
    get_luks_password
    
    # Create temporary password file
    local temp_password_file
    temp_password_file=$(mktemp)
    echo "$LUKS_PASSWORD" > "$temp_password_file"
    
    # Ensure cleanup on exit
    trap "rm -f '$temp_password_file'" EXIT
    
    log_warning "Starting installation - this will DESTROY all data on the target disk!"
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm
    if [[ "$confirm" != "yes" ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
    
    log_info "Starting nixos-anywhere installation..."
    
    # Run nixos-anywhere with our configuration
    nix run github:nix-community/nixos-anywhere --extra-experimental-features "nix-command flakes" -- \
        --flake ".#$NIXOS_PROFILE" \
        --disk-encryption-keys /tmp/secret.key "$temp_password_file" \
        -i "$SSH_KEY" \
        "$SSH_USER@$SSH_HOST"
    
    log_success "Installation completed successfully!"
    log_info "The system is now rebooting with MaxOS $NIXOS_PROFILE profile"
    log_info "You will need to enter the LUKS password during boot"
}

# Show help if no arguments provided
if [[ $# -eq 0 ]]; then
    show_usage
    exit 0
fi

# Run main function
main "$@"