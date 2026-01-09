# Migration Guide

This guide helps you migrate from the previous MaxOS configuration to the new standardized, modular system.

## Overview of Changes

### What's New
- **Standardized module patterns** with proper options and config sections
- **User configuration system** eliminates hardcoded `/home/user` paths
- **Tool bundles** group related functionality
- **Secrets management** with sops-nix integration
- **Reusable host configurations** eliminate flake.nix duplication
- **Auto-exported modules** all tools available as flake outputs

### Breaking Changes
- Hardcoded paths must be replaced with configurable options
- Simple package imports converted to proper NixOS modules
- Secrets now managed through sops-nix instead of plain files
- Host configurations use new helper functions

## Migration Steps

### 1. Update Flake Inputs

Add sops-nix to your flake inputs if not already present:

```nix
inputs = {
  # ... existing inputs
  sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### 2. Configure User Settings

Add user configuration to your host configs:

**Before:**
```nix
# Hardcoded paths everywhere
```

**After:**
```nix
maxos.user = {
  name = "youruser";
  homeDirectory = "/home/youruser";
  gitDirectory = "/home/youruser/git";
  monorepoDirectory = "/home/youruser/git/github/monorepo";
  secretsDirectory = "/home/youruser/git/github/monorepo/secrets";
};
```

### 3. Replace Direct Module Imports with Tool Bundles

**Before:**
```nix
imports = [
  ./modules/tools/docker.nix
  ./modules/tools/chromium.nix
  ./modules/tools/vscode.nix
  ./modules/tools/git-crypt.nix
  ./modules/tools/npm.nix
  # ... many individual imports
];
```

**After:**
```nix
modules.toolBundles = {
  desktop.enable = true;        # Includes chromium, terminal tools, etc.
  development.enable = true;    # Includes docker, vscode, git tools, npm, etc.
};
```

### 4. Update Host Configuration in Flake

**Before:**
```nix
G16 = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    {
      nixpkgs.config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
      nixpkgs.overlays = [ nur.overlays.default ];
    }
    self.nixosModules.scripts
    self.nixosModules.timezone
    ./hosts/G16/default.nix
    home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = lib.mkDefault "backup";
        users.user = { pkgs, ... }: {
          imports = [ ./hosts/G16/home.nix ];
          home.stateVersion = "25.11";
        };
      };
    }
  ];
};
```

**After:**
```nix
G16 = hostConfig.mkMaxOSHostWithHome {
  hostname = "G16";
  hostPath = ./hosts/G16/default.nix;
  homeConfigPath = ./hosts/G16/home.nix;
};
```

### 5. Migrate Secrets to sops-nix

**Before:**
```nix
# Plain text files in secrets directory
passwordFile = "/home/user/git/github/monorepo/secrets/password";
```

**After:**

1. Enable secrets management:
```nix
maxos.secrets.enable = true;
```

2. Initialize secrets:
```bash
maxos-secrets-init
```

3. Edit secrets file:
```bash
sops secrets/secrets.yaml
```

4. Use in modules:
```nix
modules.tools.restic = {
  enable = true;
  useSopsSecrets = true;  # Automatically uses sops secrets
};
```

### 6. Update Individual Tool Configurations

Most tools now have proper options instead of just package installation:

**Before:**
```nix
# modules/tools/docker.nix just installed docker package
```

**After:**
```nix
modules.tools.docker = {
  enable = true;
  liveRestore = false;
  enableExperimental = true;
};
```

## Module-by-Module Migration

### Simple Package Modules

Modules that only installed packages (like chromium, keepassxc) now have proper module structure:

**Before:**
```nix
# modules/tools/chromium.nix
{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ chromium ];
}
```

**After:**
```nix
# Automatically standardized
modules.tools.chromium.enable = true;
```

### Complex Modules

Modules with configuration (like restic, docker) now have options:

**Before:**
```nix
# Configuration hardcoded in module
```

**After:**
```nix
modules.tools.restic = {
  enable = true;
  bucketName = "my-backup";
  schedule = "daily";
  useSopsSecrets = true;
};
```

## Path Migration Reference

Replace hardcoded paths with configurable options:

| Old Path | New Option |
|----------|------------|
| `/home/user` | `config.maxos.user.homeDirectory` |
| `/home/user/git` | `config.maxos.user.gitDirectory` |
| `/home/user/git/github/monorepo` | `config.maxos.user.monorepoDirectory` |
| `/home/user/git/github/monorepo/secrets` | `config.maxos.user.secretsDirectory` |
| `/home/user/monorepo/tools/goose/workspace` | `config.maxos.user.workspaceDirectory` |

## Testing Your Migration

1. **Build test:** `nixos-rebuild build --flake .#your-hostname`
2. **Check services:** Verify all expected services are enabled
3. **Test secrets:** Ensure secrets are properly loaded
4. **Validate paths:** Check that all paths resolve correctly

## Common Issues

### Module Not Found
**Error:** `attribute 'somemodule' missing`

**Solution:** Check that the module is properly exported in flake.nix or use tool bundles instead.

### Secrets Not Loading
**Error:** `secret file not found`

**Solution:** Run `maxos-secrets-init` and configure your secrets with `sops secrets.yaml`.

### Path Resolution
**Error:** `path '/home/user/...' does not exist`

**Solution:** Configure `maxos.user` options to match your actual user and paths.

### Home Manager Conflicts
**Error:** `collision between files`

**Solution:** Use `home-manager.backupFileExtension = "backup"` or clean existing configs.

## Rollback Plan

If you need to rollback:

1. Keep your old configuration in a separate branch
2. Use `nixos-rebuild switch --rollback` for immediate rollback
3. Or rebuild from your old configuration: `nixos-rebuild switch --flake /path/to/old/config`

## Getting Help

- Check the logs: `journalctl -xeu nixos-rebuild`
- Validate flake: `nix flake check`
- Test build: `nixos-rebuild build --flake .#hostname`
- Review module options: `nixos-option modules.tools.toolname`