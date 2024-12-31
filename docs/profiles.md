# System Profiles

MaxOS includes several base profiles that can be used as starting points for different types of machines.

## Desktop Profile

Base configuration for desktop machines including:
- Full desktop environment
- Common applications
- Audio/Bluetooth support
- Printing capabilities
- Font configuration

To use the desktop profile:
```nix
# hosts/desktops/your-machine/default.nix
{
  imports = [
    ../../profiles/desktop.nix
    ./hardware-configuration.nix
  ];
}
```

## Server Profile

Base configuration for servers including:
- Security hardening
- Minimal package set
- Optimized for headless operation
- Network configuration

To use the server profile:
```nix
# hosts/servers/your-server/default.nix
{
  imports = [
    ../../profiles/server.nix
    ./hardware-configuration.nix
  ];
}
```

## VM Profile

Base configuration for virtual machines including:
- QEMU/SPICE integration
- VM-specific optimizations
- Basic desktop environment for testing

To use the VM profile:
```nix
# hosts/vms/your-vm/default.nix
{
  imports = [
    ../../profiles/vm.nix
    ../../profiles/vm-hardware.nix  # Shared VM hardware config
  ];
}
```

### VM Hardware Configuration

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
