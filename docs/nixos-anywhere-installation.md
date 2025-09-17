# MaxOS Installation with nixos-anywhere

This document describes how to install MaxOS using the industry-standard `nixos-anywhere` tool, which provides robust remote NixOS installations with automatic disk partitioning and LUKS encryption.

## Overview

`nixos-anywhere` replaces our custom installation scripts with a battle-tested solution that:
- ✅ Handles disk partitioning automatically via disko
- ✅ Sets up LUKS encryption securely
- ✅ Supports kexec for installation from any Linux system
- ✅ Provides robust error handling and rollback
- ✅ Works with standard NixOS flake configurations

## Prerequisites

1. **Target Machine**: Any x86_64 Linux system (live USB, existing Linux, etc.)
2. **SSH Access**: SSH key authentication to target machine
3. **Network**: Target machine must have internet access
4. **LUKS Password**: Strong password for disk encryption

## Quick Start

### 1. Basic Installation

```bash
# Install rig-minimal (ultra-fast, console-only)
./scripts/install-with-nixos-anywhere.sh -u nixos -h 192.168.1.110 -p rig-minimal

# Install full rig workstation
./scripts/install-with-nixos-anywhere.sh -u nixos -h 192.168.1.110 -p rig
```

### 2. Custom SSH Key

```bash
./scripts/install-with-nixos-anywhere.sh -u nixos -h 192.168.1.110 -p rig -i ~/.ssh/custom_key
```

## Available Profiles

| Profile | Description | Use Case |
|---------|-------------|----------|
| `rig-minimal` | Ultra-minimal console system | Rapid testing, minimal footprint |
| `rig` | Full MaxOS workstation | Production desktop with all tools |
| `G16` | Gaming workstation | High-performance gaming setup |
| `desktop-test-vm` | VM testing configuration | Virtual machine testing |

## Installation Process

1. **Validation**: Script validates SSH connectivity and profile existence
2. **LUKS Setup**: Prompts for secure disk encryption password
3. **Disk Partitioning**: disko automatically partitions and formats disk
4. **System Installation**: nixos-anywhere installs the chosen profile
5. **Reboot**: System reboots into new MaxOS installation

## Disk Layout (via disko)

```
/dev/nvme1n1
├── /dev/nvme1n1p1  512M  EFI System Partition  /boot
└── /dev/nvme1n1p2  Rest  LUKS Encrypted        /
```

## Configuration Files

### Disko Configuration
- [`hosts/rig/disko.nix`](../hosts/rig/disko.nix) - Disk partitioning for rig profile
- [`hosts/rig-minimal/disko.nix`](../hosts/rig-minimal/disko.nix) - Disk partitioning for minimal profile

### Host Configurations
- [`hosts/rig/`](../hosts/rig/) - Full workstation configuration
- [`hosts/rig-minimal/`](../hosts/rig-minimal/) - Minimal testing configuration

## Troubleshooting

### SSH Connection Issues
```bash
# Test SSH connectivity
ssh -i ~/.ssh/id_ed25519 nixos@192.168.1.110 "echo 'Connection successful'"
```

### Profile Validation
```bash
# Test profile builds locally
nix build .#nixosConfigurations.rig-minimal.config.system.build.toplevel --extra-experimental-features "nix-command flakes"
```

### Manual nixos-anywhere Usage
```bash
# Direct nixos-anywhere command
echo "your-luks-password" > /tmp/secret.key
nix run github:nix-community/nixos-anywhere --extra-experimental-features "nix-command flakes" -- \
    --flake ".#rig-minimal" \
    --disk-encryption-keys /tmp/secret.key /tmp/secret.key \
    -i ~/.ssh/id_ed25519 \
    nixos@192.168.1.110
rm /tmp/secret.key
```

## Advantages over Custom Scripts

| Feature | Custom Scripts | nixos-anywhere |
|---------|----------------|----------------|
| **Reliability** | Custom implementation | Battle-tested, community-maintained |
| **Error Handling** | Basic | Comprehensive with rollback |
| **Disk Management** | Manual partitioning | Automatic via disko |
| **Maintenance** | High maintenance burden | Zero maintenance |
| **Features** | Limited | Full feature set (kexec, VM testing, etc.) |
| **Documentation** | Custom docs | Extensive community docs |

## Migration from Old Scripts

The old custom installation scripts have been removed in favor of nixos-anywhere:

- ❌ `scripts/install-maxos-remote.sh` (removed)
- ❌ `scripts/install-maxos-layered.sh` (removed)
- ❌ `scripts/lib/` (removed)
- ✅ `scripts/install-with-nixos-anywhere.sh` (new)

## Next Steps

After installation:
1. System will reboot automatically
2. Enter LUKS password at boot prompt
3. Log in with configured user account
4. System is ready for use

For ongoing system management, use standard NixOS tools:
- `nixos-rebuild switch --flake .#profile` - Update system
- `colmena deploy` - Deploy to multiple machines