# Project Structure

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
