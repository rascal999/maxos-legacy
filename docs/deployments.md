# Deployments

## Desktop Machines

### Hero
Primary desktop configuration:
```bash
nixos-rebuild switch --flake .#desktops/hero
```

### Rig
Gaming and development machine:
```bash
nixos-rebuild switch --flake .#desktops/rig
```

## Servers

Example server:
```bash
nixos-rebuild switch --flake .#servers/example
```

## Test VMs

Test desktop configuration:
```bash
nixos-rebuild build-vm --flake .#desktop-test
./result/bin/run-nixos-vm
```

Test server configuration:
```bash
nixos-rebuild build-vm --flake .#server-test
./result/bin/run-nixos-vm
```

## Hardware Configurations

### Physical Machines
While hardware-configuration.nix files are ignored, you should:
1. Keep a backup of each machine's hardware config
2. Document any manual changes needed
3. Include instructions for generating new ones:
```bash
# Generate hardware config for a physical machine
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

### Virtual Machines
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
