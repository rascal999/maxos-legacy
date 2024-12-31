# User Configuration

MaxOS provides a unified user configuration system that makes it easy to set up new machines with your preferred settings. By default, all systems use the configuration from `templates/user.nix`, which provides:

- Default username ("user") and password ("nixos")
- US keyboard layout
- i3 desktop environment with dark theme
- Basic development tools (Python, Node.js)
- Common system utilities
- Secure defaults (firewall enabled, SSH password auth disabled)

## Getting Started

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

## Configuration Sections

### Required Settings
- Identity (username, full name, email)
- Authentication (password, SSH keys)
- Keyboard layout and options

### Common Customizations
- Shell configuration (zsh/bash, aliases, completion)
- Desktop environment (i3/gnome/kde, theme, fonts)
- Development setup (git, languages, editors)

### Advanced Settings
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
