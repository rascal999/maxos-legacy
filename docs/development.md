# Development

## Testing Changes

Use the test VMs to verify changes:
```bash
# Test desktop changes
nixos-rebuild build-vm --flake .#desktop-test

# Test server changes
nixos-rebuild build-vm --flake .#server-test
```

## Access Management

### SSH Keys Management

SSH authorized keys are stored as age-encrypted files in `secrets/ssh/authorized-keys/`:
- `root.age` - Root user's authorized keys
- `user.age` - Default user's authorized keys

#### Creating Key Files

1. Create a plain text file with the authorized keys:
```bash
# keys.txt
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host
```

2. Encrypt it using age:
```bash
age -r "age1..." -o user.age keys.txt
```

3. Add the encrypted file to the authorized-keys directory

#### Key File Format

The decrypted content should be a newline-separated list of SSH public keys:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... key1
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... key2
```

#### Integration

The ssh-keys module will:
1. Decrypt these files using the system's age key
2. Apply the keys to the appropriate users
3. Store them in /etc/ssh/authorized_keys.d/

This configuration applies to:
- All physical machines (desktops, servers)
- All test VMs
- Both root and normal user accounts

### Secrets Management

Secrets are managed using agenix:
```bash
# Edit secrets
agenix -e secrets/secrets.age

# Add new secret
scripts/manage-secrets.sh add my-secret
```

## Version Control

### Ignored Files
The following files are ignored by git:
- Build outputs (result, result-*)
- Hardware configurations (hardware-configuration.nix)
- VM images and disks (*.qcow2, *.img)
- Secrets and keys (*.age, *.key, *.pem)
- Editor and OS files (.DS_Store, .vscode/)
- Build artifacts and caches
- Local development files (.env, .direnv/)

### Hardware Configurations

#### Physical Machines
While hardware-configuration.nix files are ignored, you should:
1. Keep a backup of each machine's hardware config
2. Document any manual changes needed
3. Include instructions for generating new ones:
```bash
# Generate hardware config for a physical machine
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

#### Virtual Machines
Test VMs use a shared hardware configuration (`hosts/profiles/vm-hardware.nix`) that includes:
- Basic VM kernel modules (virtio, etc.)
- Simple filesystem setup
- Minimal hardware settings
- QEMU/KVM optimizations

This shared configuration:
- Eliminates duplication across test VMs
- Ensures consistent VM hardware settings
- Simplifies VM maintenance
- Works for both server and desktop test VMs
