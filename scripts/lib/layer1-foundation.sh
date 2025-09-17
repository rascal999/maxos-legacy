#!/usr/bin/env bash

# Layer 1: Foundation Layer
# Establish basic connectivity and prerequisites

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Layer 1 execution function
execute_layer1_foundation() {
    log_info "=== LAYER 1: Foundation Layer ==="
    log_info "Establishing basic connectivity and prerequisites..."
    
    # Test SSH connectivity
    test_ssh
    
    # Install Git on remote system
    install_git_remote
    
    # Generate SSH keys on remote system
    generate_ssh_keys_remote
    
    # Test GitHub connection from remote
    test_github_connection_remote
    
    log_success "Layer 1 (Foundation) completed successfully"
    return 0
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