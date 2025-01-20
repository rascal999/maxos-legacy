# Usage Guide

This guide covers the daily usage, customization, and maintenance of your MaxOS system.

## Testing Changes

Before applying changes to your system, test them in a VM:

```bash
./scripts/run-vm.sh
```

This creates a VM with your configuration, allowing safe testing of changes.

## System Updates

### Regular Updates

Update your system with:
```bash
# Pull latest changes
git pull

# Rebuild and switch to new configuration
sudo nixos-rebuild switch --flake .
```

### Version Upgrades

To upgrade NixOS version:

1. Update flake inputs in `flake.nix`:
   ```nix
   inputs = {
     nixpkgs.url = "github:nixos/nixpkgs/nixos-XX.YY";
     home-manager = {
       url = "github:nix-community/home-manager/release-XX.YY";
       inputs.nixpkgs.follows = "nixpkgs";
     };
   };
   ```

2. Update the system:
   ```bash
   # Update flake.lock
   nix flake update

   # Rebuild with new version
   sudo nixos-rebuild switch --flake .
   ```

## Customization

### Host Configuration

1. Create or modify host-specific settings in `hosts/`:
   ```nix
   # hosts/your-hostname/default.nix
   { config, pkgs, ... }: {
     # Your specific configurations
   }
   ```

2. Add hardware-specific settings:
   - Display configuration
   - Power management
   - Device-specific options

### Home Configuration

Modify user environment in `hosts/your-hostname/home.nix`:

```nix
{ config, pkgs, ... }: {
  # Add/modify packages
  home.packages = with pkgs; [
    # Your preferred packages
  ];

  # Configure programs
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
}
```

### Security Settings

Adjust security modules in `modules/security/`:

```nix
# Example: Customize firewall
security.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 ];
  allowPing = false;
};
```

## Maintenance

### System Cleanup

Clean old generations:
```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Remove old generations
sudo nix-collect-garbage -d
```

### Troubleshooting

1. Boot Problems:
   - Select previous generation from boot menu
   - Use `nixos-rebuild boot` instead of `switch` to test boot configurations

2. Configuration Issues:
   ```bash
   # Test configuration
   sudo nixos-rebuild test --flake .

   # Check logs
   journalctl -xb
   ```

3. Rollback:
   ```bash
   # Rollback to last generation
   sudo nixos-rebuild switch --rollback
   ```

## Tips and Tricks

### Working with Flakes

1. Update specific input:
   ```bash
   nix flake lock --update-input nixpkgs
   ```

2. Show flake information:
   ```bash
   nix flake show
   ```

### Development Environments

Create project-specific shells:

```nix
# shell.nix
{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # Project dependencies
  ];
}
```

Activate with:
```bash
nix-shell
# or with direnv
echo "use nix" > .envrc
direnv allow
```

### Common Tasks

1. Add new system package:
   ```nix
   environment.systemPackages = with pkgs; [
     your-package
   ];
   ```

2. Configure service:
   ```nix
   services.your-service = {
     enable = true;
     # Service-specific options
   };
   ```

3. Add user service:
   ```nix
   systemd.user.services.your-service = {
     Enable = true;
     # Service configuration
   };
