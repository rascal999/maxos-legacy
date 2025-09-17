# MaxOS Installation Script - Layered Architecture

## Layer Overview

The MaxOS installation script follows a layered architecture where each layer has specific responsibilities and dependencies. Each layer must complete successfully before the next layer can proceed.

## Layer 1: Foundation Layer
**Purpose**: Establish basic connectivity and prerequisites
**Functions**:
- `test_ssh()` - Verify SSH connectivity with key authentication
- `install_git_remote()` - Install Git on remote system
- `generate_ssh_keys_remote()` - Generate SSH keys for GitHub access
- `test_github_connection_remote()` - Verify GitHub SSH connectivity

**Dependencies**: None
**Outputs**: SSH connectivity, Git installed, GitHub access configured

## Layer 2: Repository Layer
**Purpose**: Clone and configure the MaxOS repository
**Functions**:
- `clone_maxos_remote()` - Clone MaxOS repository to /tmp/monorepo/maxos
- `configure_git_identity()` - Set git user for commits

**Dependencies**: Layer 1 (Git and GitHub access)
**Outputs**: MaxOS repository available on remote system

## Layer 3: Discovery Layer
**Purpose**: Discover system hardware and existing configurations
**Functions**:
- `discover_disks()` - Detect available disks and existing LUKS partitions
- `discover_profiles()` - Show available MaxOS profiles
- `detect_existing_installation()` - Check for existing MaxOS installation

**Dependencies**: Layer 2 (Repository available)
**Outputs**: Hardware inventory, profile selection, installation status

## Layer 4: Storage Layer
**Purpose**: Prepare storage and encryption
**Functions**:
- `choose_disk()` - Interactive disk selection (if needed)
- `setup_luks_encryption()` - Create LUKS encryption
- `mount_partitions()` - Mount encrypted partitions

**Dependencies**: Layer 3 (Hardware discovery)
**Outputs**: Encrypted storage ready, partitions mounted

## Layer 5: Configuration Layer
**Purpose**: Generate and update system configuration
**Functions**:
- `generate_hardware_config()` - Generate NixOS hardware configuration
- `update_boot_config()` - Update boot configuration with correct UUIDs
- `validate_configuration()` - Verify configuration correctness

**Dependencies**: Layer 4 (Storage prepared)
**Outputs**: System configuration with correct UUIDs

## Layer 6: Installation Layer
**Purpose**: Install or rebuild the system
**Functions**:
- `install_nixos()` - Fresh NixOS installation (full install mode)
- `rebuild_system_chroot()` - Rebuild existing system (boot-only mode)
- `verify_installation()` - Verify installation success

**Dependencies**: Layer 5 (Configuration ready)
**Outputs**: MaxOS system installed/updated

## Layer 7: Finalization Layer
**Purpose**: Commit changes and prepare for reboot
**Functions**:
- `commit_uuid_changes()` - Commit configuration changes to repository
- `cleanup_mounts()` - Unmount temporary mounts
- `reboot_system()` - Reboot into new system (optional)

**Dependencies**: Layer 6 (System installed)
**Outputs**: Changes committed, system ready for use

## Execution Modes

### Full Installation Mode
Executes all layers 1-7 for a complete fresh installation.

### Boot-Only Mode
Executes layers 1-3, 5-7 (skips storage layer) for configuration fixes on existing installations.

### Discovery Mode
Executes layers 1-3 only for system inspection without changes.

## Error Handling

Each layer implements:
- **Prerequisite checks**: Verify dependencies before execution
- **Idempotent operations**: Safe to run multiple times
- **Rollback capability**: Undo changes if layer fails
- **Progress tracking**: Clear indication of completion status

## Benefits

1. **Modularity**: Each layer has clear responsibilities
2. **Testability**: Individual layers can be tested in isolation
3. **Maintainability**: Easy to modify specific functionality
4. **Debugging**: Clear failure points and progress tracking
5. **Flexibility**: Different execution modes for different scenarios