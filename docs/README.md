# MaxOS - Modular NixOS Configuration

MaxOS is a comprehensive, modular NixOS configuration system designed for both desktop and server deployments. It provides a structured approach to managing NixOS configurations with standardized modules, secure secrets management, and reusable components.

## Features

- **Modular Architecture**: Standardized tool modules with proper NixOS patterns
- **Tool Bundles**: Logical groupings of related tools for easy configuration
- **Secrets Management**: Built-in support for sops-nix with age encryption
- **Reusable Host Configurations**: Eliminate duplication across multiple hosts
- **Configurable User Paths**: No hardcoded paths, fully portable configurations
- **Security-First**: Integrated security tools and practices

## Quick Start

### 1. Clone and Initial Setup

```bash
git clone <your-repo-url> /path/to/maxos
cd /path/to/maxos
```

### 2. Configure Your Host

Create a new host configuration in `hosts/your-hostname/`:

```bash
mkdir -p hosts/your-hostname
```

Create `hosts/your-hostname/default.nix`:

```nix
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Enable tool bundles
  modules.toolBundles = {
    desktop.enable = true;
    development.enable = true;
    security.enable = true;
  };

  # Enable individual tools
  modules.tools = {
    docker.enable = true;
    restic.enable = true;
  };

  # System configuration
  boot.loader.systemd-boot.enable = true;
  networking.networkmanager.enable = true;
  
  system.stateVersion = "25.05";
}
```

### 3. Add to Flake

Add your host to `flake.nix`:

```nix
nixosConfigurations = {
  # ... existing hosts
  your-hostname = hostConfig.mkMaxOSHostWithHome {
    hostname = "your-hostname";
    hostPath = ./hosts/your-hostname/default.nix;
    homeConfigPath = ./hosts/your-hostname/home.nix;
  };
};
```

### 4. Build and Switch

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

## Tool Bundles

MaxOS provides several pre-configured tool bundles:

### Desktop Bundle (`modules.toolBundles.desktop`)

- **Browsers**: Chromium
- **Terminal**: Alacritty, Tmux, Zsh with custom configuration
- **Productivity**: LogSeq
- **Utilities**: SimpleScreenRecorder, QDirStat
- **Remote Access**: Remmina, SSHFS, Mosh

### Development Bundle (`modules.toolBundles.development`)

- **Git Tools**: git-crypt, gitleaks
- **Languages**: Node.js/npm, Go
- **Editors**: VSCode with vim mode
- **Containerization**: Docker, Kind

### Security Bundle (`modules.toolBundles.security`)

- **Scanners**: Trivy, Semgrep, Syft, Grype
- **Crypto**: OpenSSL
- **Password Management**: KeePassXC

### Server Bundle (`modules.toolBundles.server`)

- **Kubernetes**: K3s, ArgoCD, Skaffold
- **Networking**: Traefik, Blocky, WireGuard
- **Databases**: MongoDB
- **Monitoring**: Grafana
- **VCS**: Forgejo + runner + CLI
- **Backup**: Restic
- **Virtualization**: QEMU

## Individual Tools

All tools can be enabled individually:

```nix
modules.tools = {
  docker.enable = true;
  docker.liveRestore = false;
  docker.enableExperimental = true;
  
  restic.enable = true;
  restic.useSopsSecrets = true;
  restic.schedule = "daily";
};
```

## Secrets Management

MaxOS uses sops-nix for secure secrets management:

### 1. Enable Secrets

```nix
maxos.secrets.enable = true;
```

### 2. Initialize Secrets

```bash
maxos-secrets-init
```

This creates an age key and example secrets file.

### 3. Edit Secrets

```bash
sops secrets/secrets.yaml
```

### 4. Use in Modules

Modules automatically use sops secrets when available:

```nix
modules.tools.restic = {
  enable = true;
  useSopsSecrets = true;  # Uses sops.secrets.restic_password, b2_access_key, etc.
};
```

## User Configuration

Configure the primary user and paths:

```nix
maxos.user = {
  name = "myuser";
  homeDirectory = "/home/myuser";
  gitDirectory = "/home/myuser/code";
  monorepoDirectory = "/home/myuser/code/maxos";
  secretsDirectory = "/home/myuser/code/maxos/secrets";
};
```

## Host Configuration Helpers

Use the provided helpers to reduce duplication:

```nix
# Simple host (no home-manager config)
simple-host = hostConfig.mkMaxOSHost {
  hostname = "simple";
  hostPath = ./hosts/simple/default.nix;
};

# Host with home-manager
full-host = hostConfig.mkMaxOSHostWithHome {
  hostname = "full";
  hostPath = ./hosts/full/default.nix;
  homeConfigPath = ./hosts/full/home.nix;
  userName = "customuser";  # Optional, defaults to "user"
};
```

## Creating New Modules

Use the module template at `templates/module-template.nix`:

1. Copy the template
2. Replace placeholders with actual values
3. Add to `modules/tools/`
4. The module is automatically exported in the flake

Example:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.mytool;
in {
  options.modules.tools.mytool = {
    enable = mkEnableOption "My awesome tool";
    
    configFile = mkOption {
      type = types.str;
      default = "${config.maxos.user.homeDirectory}/.mytool.conf";
      description = "Path to configuration file";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mytool
    ];
    
    # Additional configuration
  };
}
```

## Directory Structure

```
maxos/
├── flake.nix                 # Main flake configuration
├── lib/
│   └── host-config.nix      # Reusable host configuration helpers
├── modules/
│   ├── core/                # Core system modules
│   │   ├── user.nix        # User configuration options
│   │   └── secrets.nix     # Secrets management
│   ├── security/           # Security modules
│   ├── scripts/            # Script modules
│   ├── tools/              # Individual tool modules (67+ modules)
│   └── tool-bundles/       # Logical tool groupings
├── hosts/                  # Host-specific configurations
│   ├── G16/
│   ├── rig/
│   └── desktop-test-vm/
├── templates/              # Module templates
└── docs/                   # Documentation
```

## Migration from Old Configuration

If migrating from a previous configuration:

1. Review hardcoded paths and replace with `config.maxos.user.*`
2. Convert simple modules to use proper NixOS module structure
3. Enable sops-nix for secrets management
4. Use tool bundles instead of individual module imports where appropriate

## Exported Modules

The flake exports all modules for use in other configurations:

- `maxos.nixosModules.user` - User configuration
- `maxos.nixosModules.secrets` - Secrets management
- `maxos.nixosModules.developmentBundle` - Development tools
- `maxos.nixosModules.securityBundle` - Security tools
- `maxos.nixosModules.desktopBundle` - Desktop applications
- `maxos.nixosModules.serverBundle` - Server tools
- All individual tool modules (e.g., `maxos.nixosModules.docker`)

## Contributing

When adding new modules:

1. Use the module template
2. Follow the standardized patterns
3. Use configurable paths via `config.maxos.user.*`
4. Add sops secrets support where applicable
5. Update tool bundles as appropriate

## Troubleshooting

### Build Errors

Check module dependencies and ensure all required inputs are available.

### Secrets Issues

Use `maxos-secrets-init` to set up secrets management and ensure age keys are properly configured.

### Path Issues

Verify that `maxos.user` configuration matches your actual user and directory structure.