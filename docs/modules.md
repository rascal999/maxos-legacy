# Modules Documentation

MaxOS is built with modularity in mind, separating different aspects of the system into reusable modules.

## Security Modules

Located in `modules/security/`:

### Audit (`audit.nix`)
- System auditing configuration
- Tracks system events and security-relevant changes
- Configures audit rules and logging

### Firewall (`firewall.nix`)
- Network security configuration
- Manages incoming/outgoing connections
- Defines allowed services and ports

### Kernel (`kernel.nix`)
- Kernel hardening settings
- Sysctl security parameters
- Memory protection features

### Login (`login.nix`)
- Authentication and authorization settings
- Password policies
- Session security

### SSH (`ssh.nix`)
- SSH server configuration
- Key-based authentication settings
- Connection security parameters

## Tool Modules

Located in `modules/tools/`:

### Terminal Environment

#### Alacritty (`alacritty.nix`)
- GPU-accelerated terminal emulator
- Custom color schemes
- Font configuration
- Performance settings

#### Tmux (`tmux.nix`)
- Terminal multiplexer configuration
- Custom key bindings
- Session management
- Status bar customization

#### Zsh (`zsh.nix`)
- Shell configuration
- Aliases and functions
- Plugin management
- Prompt customization

### Desktop Environment

#### i3 Window Manager (`i3/`)
- Tiling window manager configuration
- Workspace management
- Key bindings
- Status bar settings

#### Rofi (`rofi/`)
- Application launcher
- Window switcher
- Custom themes
- Keybinding integration

#### Firefox (`firefox/`)
- Browser configuration
- Privacy settings
- Custom CSS themes
- Extension management

## Module Usage

### Including Modules

Add modules to your configuration in `flake.nix`:
```nix
{
  imports = [
    ./modules/security
    ./modules/tools/alacritty.nix
    # Add other modules as needed
  ];
}
```

### Customizing Modules

Each module can be customized through options in your host configuration:

```nix
{
  security.audit.enable = true;
  security.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
  
  programs.alacritty = {
    enable = true;
    # Add custom settings
  };
}
```

## Creating New Modules

1. Create a new `.nix` file in the appropriate directory
2. Define options and configurations
3. Make it importable in `flake.nix`
4. Document the module's options and usage

Example module structure:
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.mymodule;
in {
  options.mymodule = {
    enable = mkEnableOption "my module";
    # Define other options
  };

  config = mkIf cfg.enable {
    # Module implementation
  };
}
