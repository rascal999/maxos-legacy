#!/usr/bin/env bash

# Layer 2: Repository Layer
# Clone and configure the MaxOS repository

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Layer 2 execution function
execute_layer2_repository() {
    log_info "=== LAYER 2: Repository Layer ==="
    log_info "Cloning and configuring MaxOS repository..."
    
    # Clone MaxOS repository on remote system
    clone_maxos_remote
    
    # Configure git identity for commits
    configure_git_identity
    
    log_success "Layer 2 (Repository) completed successfully"
    return 0
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
}

# Configure git user for potential commits later
configure_git_identity() {
    log_info "Configuring git user identity..."
    ssh_exec "
        cd /tmp/monorepo &&
        git config user.email 'install-script@maxos.local' &&
        git config user.name 'MaxOS Install Script'
    "
    log_success "Git user identity configured"
}