# MaxOS

A comprehensive NixOS configuration featuring desktop and server variants with a focus on security and development workflows.

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
├── modules/          # Reusable NixOS modules
│   ├── security/    # Security configurations
│   └── tools/       # Tool-specific configurations
└── scripts/         # Utility scripts
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
