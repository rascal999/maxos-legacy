# MaxOS

A NixOS configuration system for managing multiple machines with different profiles.

## Documentation

- [Quickstart](docs/quickstart.md) - Get started quickly with a test VM
- [Project Structure](docs/structure.md) - Overview of repository organization
- [User Configuration](docs/user-configuration.md) - Configure user settings and preferences
- [System Profiles](docs/profiles.md) - Available system profiles (desktop, server, VM)
- [Deployments](docs/deployments.md) - How to deploy to different machines
- [Adding New Machines](docs/adding-machines.md) - Guide for adding new machines
- [Development](docs/development.md) - Development guidelines and practices
- [Common Tasks](docs/common-tasks.md) - Common operations and maintenance
- [Contributing](docs/contributing.md) - Guidelines for contributing

## Overview

MaxOS provides:
- Unified user configuration system
- Pre-configured profiles for different machine types
- Test VMs for development
- Secret management with agenix
- Comprehensive documentation

## Quick Test

Try it out immediately with a desktop VM:
```bash
# Build and run desktop test VM
nixos-rebuild build-vm --flake .#desktop-test
./result/bin/run-nixos-vm

# Login credentials:
# Username: user
# Password: nixos
```

## License

MIT
