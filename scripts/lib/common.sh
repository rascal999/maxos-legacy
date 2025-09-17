#!/usr/bin/env bash

# MaxOS Installation Script Common Library
# Shared functions for MaxOS installation and configuration scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Commit and push UUID changes
commit_uuid_changes() {
    log_info "Committing and pushing UUID changes to repository..."
    
    ssh_exec "
        cd /tmp/monorepo &&
        git add . &&
        if git diff --staged --quiet; then
            echo 'No changes to commit'
        else
            git commit -m 'Update $NIXOS_PROFILE boot configuration with actual disk UUIDs from installation' &&
            git push
        fi
    "
    
    log_success "UUID changes committed and pushed to repository"
}