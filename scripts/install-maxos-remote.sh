#!/usr/bin/env bash

# MaxOS Remote Installation Script
# This script runs on a NixOS machine and uses SSH to install MaxOS on a remote live USB system

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
TARGET_DISK=""
NIXOS_PROFILE=""

# SSH options for key-only authentication
SSH_OPTS="-o PasswordAuthentication=no -o PubkeyAuthentication=yes -o PreferredAuthentications=publickey -o BatchMode=yes -o StrictHostKeyChecking=no -o ConnectTimeout=10"
SSH_OPTS_INTERACTIVE="-o PasswordAuthentication=no -o PubkeyAuthentication=yes -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no"

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

# Common SSH execution function
ssh_exec() {
    local interactive=false
    if [[ "$1" == "-t" ]]; then
        interactive=true
        shift
    fi
    
    local command="$1"
    
    if [[ "$interactive" == "true" ]]; then
        ssh -t $SSH_OPTS_INTERACTIVE "$SSH_USER@$SSH_HOST" "$command"
    else
        ssh $SSH_OPTS "$SSH_USER@$SSH_HOST" "$command"
    fi
}

# Check if step is already completed
check_git_installed() {
    ssh_exec "command -v git >/dev/null 2>&1"
}

check_ssh_key_exists() {
    ssh_exec "[[ -f ~/.ssh/id_ed25519 ]]"
}

check_repo_cloned() {
    ssh_exec "[[ -d /tmp/monorepo/maxos ]]"
}

check_disk_setup() {
    # Check if any disk has LUKS partitions (crypto_LUKS filesystem)
    ssh_exec "sudo blkid -t TYPE=crypto_LUKS >/dev/null 2>&1"
}

check_partitions_mounted() {
    ssh_exec "[[ -d /mnt/boot && -d /mnt/etc ]]"
}

check_hardware_config_generated() {
    ssh_exec "[[ -f /mnt/etc/nixos/hardware-configuration.nix ]]"
}

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
            EFI_UUID='$efi_uuid' &&
            ROOT_UUID='$root_uuid' &&
            # Update UUIDs in the target profile's boot.nix using generic patterns
            sed -i \"s|device = \\\"/dev/disk/by-uuid/[a-fA-F0-9-]*\\\"|device = \\\"/dev/disk/by-uuid/\$LUKS_UUID\\\"|g\" hosts/$NIXOS_PROFILE/boot.nix &&
            # More specific replacements for different filesystem types
            sed -i \"s|/dev/disk/by-uuid/[a-fA-F0-9-]* # LUKS|/dev/disk/by-uuid/\$LUKS_UUID|g\" hosts/$NIXOS_PROFILE/boot.nix &&
            sed -i \"s|/dev/disk/by-uuid/[A-F0-9-]* # EFI|/dev/disk/by-uuid/\$EFI_UUID|g\" hosts/$NIXOS_PROFILE/boot.nix &&
            sed -i \"s|/dev/disk/by-uuid/[a-fA-F0-9-]* # Root|/dev/disk/by-uuid/\$ROOT_UUID|g\" hosts/$NIXOS_PROFILE/boot.nix &&
            echo 'Boot configuration updated successfully for profile: $NIXOS_PROFILE'
        else
            echo 'Warning: No boot.nix found for profile $NIXOS_PROFILE, using hardware-configuration.nix'
        fi
    "
    
    log_success "Boot configuration updated with correct UUIDs"
}

# Show usage
show_usage() {
    cat << EOF
MaxOS Remote Installation Script

This script runs on a NixOS machine and uses SSH to install MaxOS 
on a remote NixOS live USB system with LUKS encryption.

Usage: $0 -u SSH_USER -h SSH_HOST

Required Options:
    -u, --user USER         SSH username (e.g., nixos)
    -h, --host HOST         SSH hostname/IP (e.g., 192.168.1.110)
    --help                  Show this help message

Examples:
    $0 -u nixos -h 192.168.1.110

The script will:
1. Install Git on remote system
2. Generate SSH keys on remote system
3. Wait for you to add the key to GitHub
4. Clone MaxOS repository on remote system
5. Show available disks and let you choose
6. Show available NixOS profiles and let you choose
7. Set up LUKS encryption on chosen disk
8. Install NixOS with chosen profile

WARNING: This will DESTROY all data on the chosen disk!
NOTE: This script requires SSH key authentication and will fail if password authentication is needed.
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

# Test SSH connectivity (SSH key only, no password)
test_ssh() {
    log_info "Testing SSH connectivity to $SSH_USER@$SSH_HOST..."
    if ssh_exec "echo 'SSH connection successful'" >/dev/null 2>&1; then
        log_success "SSH connection successful"
    else
        log_error "Cannot connect to $SSH_USER@$SSH_HOST via SSH with key authentication"
        log_error "Please ensure SSH key authentication is set up"
        log_error "This script requires SSH key authentication and will not work with passwords"
        exit 1
    fi
}

# Install Git on remote system
install_git_remote() {
    if check_git_installed; then
        log_success "Git is already installed on remote system"
        return 0
    fi
    
    log_info "Installing Git on remote system..."
    ssh_exec "nix-env -iA nixos.git"
    log_success "Git installed on remote system"
}

# Generate SSH keys on remote system
generate_ssh_keys_remote() {
    if check_ssh_key_exists; then
        log_success "SSH key already exists on remote system"
        
        # Still create SSH config for GitHub in case it's missing
        ssh_exec "mkdir -p ~/.ssh && cat > ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
EOF
chmod 600 ~/.ssh/config"
        
        # Display public key for verification
        echo
        log_info "Current SSH public key on remote system:"
        echo "========================================="
        ssh_exec "cat ~/.ssh/id_ed25519.pub"
        echo "========================================="
        echo
        echo "If this key is not in your GitHub account, please add it:"
        echo "1. Go to GitHub.com → Settings → SSH and GPG keys"
        echo "2. Click 'New SSH key'"
        echo "3. Paste the above key"
        echo "4. Save the key"
        echo
        read -p "Press Enter to continue (assuming key is already in GitHub)..."
        return 0
    fi
    
    log_info "Generating SSH keys on remote system..."
    ssh_exec "ssh-keygen -t ed25519 -C '$SSH_USER@$SSH_HOST' -f ~/.ssh/id_ed25519 -N ''"
    log_success "SSH key generated on remote system"
    
    # Create SSH config for GitHub
    ssh_exec "mkdir -p ~/.ssh && cat > ~/.ssh/config << 'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    StrictHostKeyChecking no
EOF
chmod 600 ~/.ssh/config"
    
    log_success "SSH configuration created on remote system"
    
    # Display public key
    echo
    log_warning "Please add this SSH public key to your GitHub account:"
    echo "=========================================================="
    ssh_exec "cat ~/.ssh/id_ed25519.pub"
    echo "=========================================================="
    echo
    echo "1. Go to GitHub.com → Settings → SSH and GPG keys"
    echo "2. Click 'New SSH key'"
    echo "3. Paste the above key"
    echo "4. Save the key"
    echo
    read -p "Press Enter after you've added the key to GitHub..."
}

# Test GitHub connection from remote
test_github_connection_remote() {
    log_info "Testing GitHub SSH connection from remote system..."
    if ssh_exec "ssh -T git@github.com 2>&1 | grep -q 'successfully authenticated'"; then
        log_success "GitHub SSH connection successful from remote system"
    else
        log_error "GitHub SSH connection failed. Please check your SSH key setup."
        exit 1
    fi
}

# Clone MaxOS repository on remote system
clone_maxos_remote() {
    if check_repo_cloned; then
        log_success "MaxOS repository already cloned, updating..."
        ssh_exec "cd /tmp/monorepo/maxos && git stash && git pull && git stash pop 2>/dev/null || true"
        log_success "Repository updated"
    else
        log_info "Cloning MaxOS repository on remote system..."
        ssh_exec "
            cd /tmp &&
            rm -rf monorepo &&
            git clone git@github.com:rascal999/monorepo.git &&
            cd monorepo/maxos &&
            ls -la
        "
        log_success "MaxOS repository cloned to /tmp/monorepo/maxos on remote system"
    fi
    
    # Ensure git tree is clean for flake operations
    log_info "Ensuring git repository is clean..."
    ssh_exec "cd /tmp/monorepo && git status --porcelain | wc -l | grep -q '^0$' || (git add . && git commit -m 'Auto-commit during installation')"
    log_success "Git repository is clean"
}

# Show available disks on remote system
show_disks_remote() {
    log_info "Available disks on remote system:"
    echo "=================================="
    ssh_exec "lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk"
    echo
}

# Choose disk for installation
choose_disk() {
    show_disks_remote
    
    # Get list of available disks
    local disk_list
    disk_list=$(ssh_exec "lsblk -d -n -o NAME | grep -E '^(sd|nvme|vd)'")
    local disks=($disk_list)
    
    echo "Available disks for installation:"
    for i in "${!disks[@]}"; do
        echo "$((i+1)). /dev/${disks[i]}"
    done
    echo
    
    while true; do
        read -p "Choose disk number (1-${#disks[@]}): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#disks[@]}" ]; then
            TARGET_DISK="/dev/${disks[$((choice-1))]}"
            break
        else
            log_error "Invalid choice. Please enter a number between 1 and ${#disks[@]}"
        fi
    done
    
    log_warning "Selected disk: $TARGET_DISK"
    ssh_exec "lsblk $TARGET_DISK"
    echo
    log_warning "THIS WILL DESTROY ALL DATA ON $TARGET_DISK!"
    read -p "Are you sure? (type 'yes' to confirm): " confirm
    if [[ "$confirm" != "yes" ]]; then
        log_info "Installation cancelled"
        exit 0
    fi
}

# Show available NixOS profiles
show_profiles() {
    log_info "Available MaxOS profiles:"
    echo "========================="
    
    local profile_list
    profile_list=$(ssh_exec "cd /tmp/monorepo/maxos && ls hosts/")
    local profiles=($profile_list)
    
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

# Setup LUKS encryption on remote system
setup_luks_remote() {
    if check_disk_setup; then
        log_success "LUKS encryption already set up"
        return 0
    fi
    
    log_info "Setting up LUKS encryption on $TARGET_DISK..."
    ssh_exec -t "
        cd /tmp/monorepo/maxos &&
        sudo ./scripts/setup-luks.sh $TARGET_DISK
    "
    
    log_success "LUKS encryption setup completed"
}

# Force setup LUKS encryption (for fresh installs)
setup_luks_remote_force() {
    log_info "Setting up LUKS encryption on $TARGET_DISK (forced)..."
    ssh_exec -t "
        cd /tmp/monorepo/maxos &&
        sudo ./scripts/setup-luks.sh $TARGET_DISK
    "
    
    log_success "LUKS encryption setup completed"
}

# Mount partitions on remote system
mount_partitions_remote() {
    if check_partitions_mounted; then
        log_success "Partitions already mounted"
        return 0
    fi
    
    log_info "Mounting partitions on remote system..."
    ssh_exec "
        # Get partition names
        if [[ '$TARGET_DISK' =~ ^/dev/nvme ]]; then
            EFI_PART='${TARGET_DISK}p1'
            ROOT_PART='${TARGET_DISK}p2'
        else
            EFI_PART='${TARGET_DISK}1'
            ROOT_PART='${TARGET_DISK}2'
        fi &&
        
        # Mount root partition
        sudo mount /dev/mapper/cryptroot /mnt &&
        
        # Create and mount boot partition
        sudo mkdir -p /mnt/boot &&
        sudo mount \$EFI_PART /mnt/boot &&
        
        echo 'Partitions mounted successfully'
    "
    
    log_success "Partitions mounted successfully"
}

# Generate hardware configuration on remote system
generate_hardware_config_remote() {
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

# Install NixOS with chosen profile
install_nixos_remote() {
    log_info "Installing NixOS with $NIXOS_PROFILE profile on remote system..."
    
    ssh_exec -t "
        cd /tmp/monorepo/maxos &&
        sudo nixos-install --flake '.#$NIXOS_PROFILE' --root /mnt
    "
    
    log_success "NixOS installation completed"
}

# Reboot remote system
reboot_remote() {
    log_info "Installation complete. Rebooting remote system..."
    
    ssh_exec "sudo reboot" || true
    
    log_success "Remote system is rebooting"
    log_info "You will need to enter the LUKS passphrase during boot"
}

# Main installation function
main() {
    echo "MaxOS Remote Installation Script"
    echo "================================"
    echo
    
    # Parse arguments
    parse_args "$@"
    
    # Test SSH connectivity
    test_ssh
    
    # Install Git on remote system
    install_git_remote
    
    # Generate SSH keys on remote system
    generate_ssh_keys_remote
    
    # Test GitHub connection from remote
    test_github_connection_remote
    
    # Clone MaxOS repository on remote system
    clone_maxos_remote
    
    # Check if LUKS disk already exists and give user choice
    if check_disk_setup; then
        log_warning "LUKS encrypted disk detected on remote system"
        
        # Find the disk that contains LUKS partitions
        local luks_partition
        luks_partition=$(ssh_exec "sudo blkid -t TYPE=crypto_LUKS -o device | head -1")
        if [[ -z "$luks_partition" ]]; then
            log_error "Could not detect LUKS partition"
            exit 1
        fi
        
        # Extract base disk name from partition
        if [[ "$luks_partition" =~ ^/dev/nvme ]]; then
            TARGET_DISK=$(echo "$luks_partition" | sed 's/p[0-9]*$//')
        else
            TARGET_DISK=$(echo "$luks_partition" | sed 's/[0-9]*$//')
        fi
        
        log_info "Detected target disk: $TARGET_DISK (LUKS partition: $luks_partition)"
        echo
        echo "Options:"
        echo "1. Continue with existing LUKS setup (preserve data)"
        echo "2. Fresh install (DESTROY ALL DATA and recreate LUKS)"
        echo
        
        while true; do
            read -p "Choose option (1 or 2): " choice
            case $choice in
                1)
                    log_info "Continuing with existing LUKS setup..."
                    # Prompt to open LUKS partition if not already open
                    if ! ssh_exec "sudo cryptsetup status cryptroot >/dev/null 2>&1"; then
                        log_info "LUKS partition needs to be opened..."
                        ssh_exec -t "sudo cryptsetup open $luks_partition cryptroot"
                        log_success "LUKS partition opened"
                    else
                        log_success "LUKS partition already open"
                    fi
                    break
                    ;;
                2)
                    log_warning "Fresh install selected - ALL DATA WILL BE DESTROYED!"
                    echo
                    log_warning "This will completely wipe $TARGET_DISK and recreate LUKS encryption"
                    read -p "Are you absolutely sure? (type 'DESTROY' to confirm): " confirm
                    if [[ "$confirm" != "DESTROY" ]]; then
                        log_info "Fresh install cancelled"
                        exit 0
                    fi
                    
                    log_info "Performing fresh install on $TARGET_DISK..."
                    # Close any open LUKS devices first
                    ssh_exec "sudo cryptsetup close cryptroot 2>/dev/null || true"
                    # Setup LUKS encryption (this will wipe the disk)
                    setup_luks_remote_force
                    break
                    ;;
                *)
                    log_error "Invalid choice. Please enter 1 or 2"
                    ;;
            esac
        done
    else
        # No LUKS found, proceed with normal disk selection
        choose_disk
        # Setup LUKS encryption
        setup_luks_remote
    fi
    
    # Choose NixOS profile
    show_profiles
    
    # Mount partitions
    mount_partitions_remote
    
    # Generate hardware configuration
    generate_hardware_config_remote
    
    # Update boot configuration with correct UUIDs
    update_boot_config
    
    # Install NixOS
    install_nixos_remote
    
    # Reboot
    reboot_remote
    
    echo
    log_success "MaxOS installation completed successfully!"
    log_info "The remote system is now rebooting with MaxOS $NIXOS_PROFILE profile"
    log_info "You will need to enter the LUKS passphrase during boot"
}

# Show help if no arguments provided
if [[ $# -eq 0 ]]; then
    show_usage
    exit 0
fi

# Run main function
main "$@"