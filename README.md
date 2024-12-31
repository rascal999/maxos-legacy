# MaxOS

A NixOS configuration system for managing multiple machines with different profiles.

## Quickstart

Test the system immediately with a desktop VM:
```bash
# Build and run desktop test VM
nixos-rebuild build-vm --flake .#desktop-test
./result/bin/run-nixos-vm

# Login credentials:
# Username: user
# Password: nixos
```

The VM comes with:
- i3 desktop environment
- Development tools (Python, Node.js)
- Common utilities
- Dark theme and modern fonts

Want to customize? Check out:
- templates/user.nix - Default configuration with comments
- templates/example-user.nix - Complete example with all options

Then override what you need:
```nix
# hosts/desktops/your-machine/default.nix
{
  userConfig.desktop.environment = "gnome";  # Just switch to GNOME
}
```

## Structure

```
.
├── flake.nix          # Main configuration entry point
├── templates/         # Configuration templates
│   ├── user.nix         # Default user configuration template
│   └── example-user.nix # Example user configuration with all options
├── home/              # Home-manager configurations
│   ├── common/        # Shared home-manager modules
│   └── profiles/      # User environment profiles
├── hosts/             # Host configurations
│   ├── common/        # Shared system configurations
│   ├── profiles/      # Base profiles for different machine types
│   │   ├── desktop.nix   # Desktop environment profile
│   │   ├── server.nix    # Server profile
│   │   └── vm.nix        # VM optimizations
│   ├── desktops/     # Desktop machine configurations
│   │   ├── hero/        # Primary desktop
│   │   └── rig/         # Gaming/Development rig
│   ├── servers/      # Server configurations
│   │   └── example/     # Example server
│   └── vms/          # Test VMs
│       ├── desktop-test/  # Desktop profile testing
│       └── server-test/   # Server profile testing
├── modules/          # Custom NixOS modules
├── overlays/         # Package overlays
├── scripts/         # Utility scripts
└── secrets/         # Secret management (agenix)
```

## User Configuration

MaxOS provides a unified user configuration system that makes it easy to set up new machines with your preferred settings. By default, all systems use the configuration from `templates/user.nix`, which provides:

- Default username ("user") and password ("nixos")
- US keyboard layout
- i3 desktop environment with dark theme
- Basic development tools (Python, Node.js)
- Common system utilities
- Secure defaults (firewall enabled, SSH password auth disabled)

You can override these defaults in your machine's configuration:

```nix
# hosts/desktops/your-machine/default.nix
{
  userConfig = {
    identity = {
      username = "alice";      # Override default username
      fullName = "Alice Smith";
      email = "alice@example.com";
    };
    desktop.environment = "gnome";  # Use GNOME instead of i3
  };
}
```

All user-specific settings can be managed in a single file, including:

- User identity and authentication
- Keyboard layout and options
- Shell preferences and aliases
- Desktop environment settings
- Development tools and preferences
- Security and privacy settings
- Backup configuration

### Getting Started

The default user configuration in `templates/user.nix` is automatically included in all systems. You can either:

1. Use the defaults and override specific settings in your machine configuration:
```nix
# hosts/desktops/your-machine/default.nix
{
  imports = [
    ../../profiles/desktop.nix
    ./hardware-configuration.nix
  ];
  
  # Override specific settings
  userConfig = {
    identity = {
      username = "alice";
      fullName = "Alice Smith";
      email = "alice@example.com";
    };
  };
  
  networking.hostName = "your-machine";
}
```

2. Or create a complete custom configuration:
```bash
# Copy template to users directory
cp templates/user.nix users/your-username.nix

# Edit with your settings
$EDITOR users/your-username.nix

# Import in your machine configuration
# hosts/desktops/your-machine/default.nix
{
  imports = [
    ../../profiles/desktop.nix
    ./hardware-configuration.nix
    ../../../users/your-username.nix  # Your custom configuration
  ];
  
  networking.hostName = "your-machine";
}
```

The template includes:
- Required settings (username, authentication, keyboard)
- Common customizations (shell, desktop, development)
- Advanced settings (security, backup, network mounts)

See `templates/example-user.nix` for a complete example with all available options.

### Configuration Sections

#### Required Settings
- Identity (username, full name, email)
- Authentication (password, SSH keys)
- Keyboard layout and options

#### Common Customizations
- Shell configuration (zsh/bash, aliases, completion)
- Desktop environment (i3/gnome/kde, theme, fonts)
- Development setup (git, languages, editors)

#### Advanced Settings
- Additional system groups
- Extra packages
- System services
- Network mounts
- Security settings (GPG, YubiKey, firewall)
- Backup configuration

### Example Configuration

See `templates/example-user.nix` for a detailed example that includes:
- Development environment setup
- Desktop customization
- Common applications
- Security settings
- Backup configuration

## Profiles

### Desktop Profile
Base configuration for desktop machines including:
- Full desktop environment
- Common applications
- Audio/Bluetooth support
- Printing capabilities
- Font configuration

### Server Profile
Base configuration for servers including:
- Security hardening
- Minimal package set
- Optimized for headless operation
- Network configuration

### VM Profile
Base configuration for virtual machines including:
- QEMU/SPICE integration
- VM-specific optimizations
- Basic desktop environment for testing

## Deployments

### Desktop Machines

#### Hero
Primary desktop configuration:
```bash
nixos-rebuild switch --flake .#desktops/hero
```

#### Rig
Gaming and development machine:
```bash
nixos-rebuild switch --flake .#desktops/rig
```

### Servers

Example server:
```bash
nixos-rebuild switch --flake .#servers/example
```

### Test VMs

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

## Adding New Machines

### New Desktop

1. Create new directory:
```bash
mkdir -p hosts/desktops/new-desktop
```

2. Create configuration:
```nix
# hosts/desktops/new-desktop/default.nix
{
  imports = [
    ../../profiles/desktop.nix
    ./hardware-configuration.nix
  ];
  networking.hostName = "new-desktop";
  # Add machine-specific configurations
}
```

3. Add to flake.nix:
```nix
nixosConfigurations."desktops/new-desktop" = lib.nixosSystem {
  inherit system;
  modules = [
    ./hosts/desktops/new-desktop
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }
  ];
  specialArgs = { inherit inputs; };
};
```

### New Server

Similar process as desktop, but use:
```bash
mkdir -p hosts/servers/new-server
```

And import the server profile:
```nix
imports = [
  ../../profiles/server.nix        # Note: Path relative to hosts/servers/new-server/
  ./hardware-configuration.nix
];
```

Note: When importing profiles, ensure paths are relative to your configuration's location:
- For desktops: ../../profiles/desktop.nix (from hosts/desktops/[name]/)
- For servers: ../../profiles/server.nix (from hosts/servers/[name]/)
- For VMs: ../../profiles/vm.nix (from hosts/vms/[name]/)

## Development

### Testing Changes

Use the test VMs to verify changes:
```bash
# Test desktop changes
nixos-rebuild build-vm --flake .#desktop-test

# Test server changes
nixos-rebuild build-vm --flake .#server-test
```

### Access Management

#### SSH Keys
The following SSH key is trusted across all deployments for both root and user access:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICxYneUbKLM8Bw/+WIqXplOtOoOmnGmWh9lg/7wliAUn user@rig
```

This is configured in `hosts/common/users.nix` and applies to:
- All physical machines (desktops, servers)
- All test VMs
- Both root and normal user accounts

#### Secrets Management

Secrets are managed using agenix:
```bash
# Edit secrets
agenix -e secrets/secrets.age

# Add new secret
scripts/manage-secrets.sh add my-secret
```

## Common Tasks

### Update System
```bash
# Update flake inputs
nix flake update

# Update and switch to new configuration
nixos-rebuild switch --flake .#desktops/hero
```

### Clean Up
```bash
# Remove old generations
sudo nix-collect-garbage -d

# Remove specific generation
sudo nix-env --delete-generations old
```

### Debug
```bash
# Show system closure size
nix path-info -Sh /run/current-system

# Show dependency graph
nix-store -q --graph /run/current-system | dot -Tsvg > system-graph.svg
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

The hardware configuration is automatically included by test VMs through:
```nix
imports = [
  ../../profiles/vm.nix             # VM-specific optimizations
  ../../profiles/vm-hardware.nix    # Shared VM hardware config
  # ... other imports
];
```

## Contributing

1. Create a new branch for your changes
2. Test changes using the appropriate test VM
3. Update documentation if adding new features
4. Ensure no sensitive data or machine-specific configs are committed
5. Submit a pull request

## License

MIT
