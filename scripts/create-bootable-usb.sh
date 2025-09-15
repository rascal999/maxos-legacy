#!/usr/bin/env bash

# MaxOS Bootable USB Creator
# This script creates a bootable USB drive with MaxOS installation capabilities

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAXOS_DIR="$(dirname "$SCRIPT_DIR")"
USB_DEVICE=""
ISO_TYPE="minimal"

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
MaxOS Bootable USB Creator

Usage: $0 [OPTIONS]

Options:
    -d, --device DEVICE     USB device (e.g., /dev/sdb)
    -t, --type TYPE         ISO type: minimal, graphical (default: minimal)
    -h, --help             Show this help message

Examples:
    $0 -d /dev/sdb                          # Create minimal USB
    $0 -d /dev/sdb -t graphical             # Create graphical USB

WARNING: This will DESTROY all data on the specified USB device!
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--device)
                USB_DEVICE="$2"
                shift 2
                ;;
            -t|--type)
                ISO_TYPE="$2"
                shift 2
                ;;
            -h|--help)
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
}

# Validate arguments
validate_args() {
    if [[ -z "$USB_DEVICE" ]]; then
        log_error "USB device not specified. Use -d /dev/sdX"
        show_usage
        exit 1
    fi

    if [[ ! -b "$USB_DEVICE" ]]; then
        log_error "Device $USB_DEVICE does not exist or is not a block device"
        exit 1
    fi

    if [[ "$ISO_TYPE" != "minimal" && "$ISO_TYPE" != "graphical" ]]; then
        log_error "Invalid ISO type: $ISO_TYPE. Must be 'minimal' or 'graphical'"
        show_usage
        exit 1
    fi
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# List available USB devices
list_usb_devices() {
    log_info "Available USB devices:"
    lsblk -d -o NAME,SIZE,MODEL,TRAN | grep usb || log_warning "No USB devices found"
    echo
}

# Confirm device selection
confirm_device() {
    log_warning "Selected device: $USB_DEVICE"
    lsblk "$USB_DEVICE" 2>/dev/null || {
        log_error "Cannot read device information"
        exit 1
    }
    echo
    log_warning "THIS WILL DESTROY ALL DATA ON $USB_DEVICE!"
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " -r
    if [[ $REPLY != "yes" ]]; then
        log_info "Operation cancelled"
        exit 0
    fi
}


# Get ISO path based on type
get_iso_path() {
    case "$ISO_TYPE" in
        "minimal")
            if [[ -f "/srv/http/images/nixos-minimal.iso" ]]; then
                echo "/srv/http/images/nixos-minimal.iso"
            else
                log_error "Minimal ISO not found. Run: sudo /etc/pxe/download-nixos-images.sh"
                exit 1
            fi
            ;;
        "graphical")
            if [[ -f "/srv/http/images/nixos-graphical.iso" ]]; then
                echo "/srv/http/images/nixos-graphical.iso"
            else
                log_error "Graphical ISO not found. Run: sudo /etc/pxe/download-nixos-images.sh"
                exit 1
            fi
            ;;
        *)
            log_error "Invalid ISO type: $ISO_TYPE"
            exit 1
            ;;
    esac
}

# Create bootable USB
create_bootable_usb() {
    local iso_path="$1"
    
    log_info "Creating bootable USB from: $iso_path"
    
    # Validate ISO file exists
    if [[ ! -f "$iso_path" ]]; then
        log_error "ISO file not found: $iso_path"
        exit 1
    fi
    
    # Unmount any mounted partitions
    log_info "Unmounting any mounted partitions..."
    umount "${USB_DEVICE}"* 2>/dev/null || true
    
    # Write ISO to USB device
    log_info "Writing ISO to $USB_DEVICE (this may take several minutes)..."
    dd if="$iso_path" of="$USB_DEVICE" bs=4M status=progress oflag=sync
    
    # Sync to ensure all data is written
    log_info "Syncing data to USB device..."
    sync
    
    log_success "Bootable USB created successfully!"
}


# Display final instructions
show_final_instructions() {
    log_success "MaxOS bootable USB creation completed!"
    echo
    echo "USB Device: $USB_DEVICE"
    echo "ISO Type: $ISO_TYPE"
    echo
    echo "To use the USB:"
    echo "1. Insert USB into target machine"
    echo "2. Boot from USB (may need to change boot order in BIOS)"
    echo "3. Follow standard NixOS installation procedures"
    echo
    echo "For MaxOS installation:"
    echo "1. Boot from this USB"
    echo "2. Open terminal and run:"
    echo "   git clone https://github.com/rascal999/monorepo.git"
    echo "   cd monorepo/maxos"
    echo "   sudo nixos-install --flake .#<config-name>"
    echo
    echo "Available MaxOS configurations: G16, rig, server, desktop-test-vm"
    echo
    log_info "The USB is ready for MaxOS installation!"
}

# Main execution
main() {
    echo "MaxOS Bootable USB Creator"
    echo "========================="
    echo
    
    # Parse arguments
    parse_args "$@"
    
    # Show help if no arguments
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi
    
    # Validate environment
    check_root
    validate_args
    
    # Show available devices
    list_usb_devices
    
    # Confirm device selection
    confirm_device
    
    # Get ISO path
    local iso_path
    iso_path=$(get_iso_path)
    
    # Validate ISO path was returned
    if [[ -z "$iso_path" ]]; then
        log_error "Failed to get ISO path"
        exit 1
    fi
    
    # Create bootable USB
    create_bootable_usb "$iso_path"
    
    # Show final instructions
    show_final_instructions
}

# Run main function
main "$@"