# MaxOS

A comprehensive NixOS configuration featuring desktop and server variants with a focus on security and development workflows..

Repository: https://github.com/rascal999/monorepo/tree/main/maxos

## Features

- **Multiple Host Configurations**
  - Desktop environment with i3 window manager
  - Server configuration
  - Test VM configuration for safe testing

- **Security-Focused**
  - Hardened kernel configuration
  - Firewall rules
  - SSH security
  - Audit system
  - Login security

- **Development Environment**
  - VSCode, Neovim
  - Git + GitHub CLI
  - Development tools (ripgrep, fd, jq)
  - direnv + nix-direnv integration

- **Desktop Environment**
  - i3 window manager
  - Rofi launcher
  - Custom Firefox configuration
  - Alacritty terminal
  - tmux + Zsh setup

## Documentation

- [Installation Guide](docs/installation.md) - Complete installation instructions
- [Module Documentation](docs/modules.md) - Details about available modules
- [Usage Guide](docs/usage.md) - Daily usage and maintenance
- [Layered Architecture](docs/layered-architecture.md) - New recursion-safe module structure
- [Recursion Prevention Guide](docs/recursion-prevention-guide.md) - Architectural patterns and design principles

## Quick Start

1. Follow the [Installation Guide](docs/installation.md) to set up NixOS with encryption
2. Configure your system using the [Module Documentation](docs/modules.md)
3. Refer to the [Usage Guide](docs/usage.md) for daily operations

## Project Structure

```
maxos/
├── docs/              # Detailed documentation
├── flake.nix         # Main Nix Flake configuration
├── hosts/            # Host-specific configurations
│   ├── desktop/      # Desktop configuration
│   ├── server/       # Server configuration
│   └── desktop-test-vm/ # VM testing configuration
├── modules/          # Layered NixOS modules (recursion-safe)
│   ├── 01-core/      # Foundation layer (user, secrets, fonts)
│   ├── 02-hardware/  # Hardware abstraction (laptop, desktop, server)
│   ├── 03-services/  # System services (docker, k3s, wireguard)
│   ├── 04-applications/ # User applications (vscode, alacritty, zsh)
│   ├── 05-bundles/   # Tool combinations (development, security, gaming)
│   ├── 06-profiles/  # Complete environments (workstation, server)
│   ├── security/     # Security configurations
│   └── scripts/      # Script modules
├── templates/        # Safe module templates
└── scripts/         # Utility scripts
```

## Architecture

MaxOS uses a **layered architecture** to prevent infinite recursion issues:

- **Layer separation**: Higher layers can depend on lower layers, never the reverse
- **Context separation**: System and home-manager modules are completely separate
- **Safe patterns**: All modules follow recursion-prevention guidelines
- **Enhanced validation**: Comprehensive dependency checking and error reporting

See [Layered Architecture](docs/layered-architecture.md) for detailed information.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
