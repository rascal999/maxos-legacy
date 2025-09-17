# MaxOS Layered Architecture

This document describes the new layered architecture implemented to prevent infinite recursion issues in MaxOS.

## Overview

The MaxOS module system has been restructured into a layered architecture that follows strict dependency rules to prevent circular dependencies and infinite recursion during Nix evaluation.

## Layer Structure

```
modules/
├── 01-core/          # Foundation layer (no dependencies)
│   ├── system/       # System-level core modules
│   │   ├── user.nix
│   │   ├── secrets.nix
│   │   ├── fonts.nix
│   │   └── validation-enhanced.nix
│   └── home/         # Home-manager core modules (if any)
│
├── 02-hardware/      # Hardware abstraction (depends on core)
│   ├── system/
│   │   ├── laptop.nix
│   │   ├── desktop.nix
│   │   └── server.nix
│   └── home/         # Hardware-specific home configs
│
├── 03-services/      # System services (depends on core+hardware)
│   ├── system/
│   │   ├── docker.nix
│   │   ├── k3s.nix
│   │   └── wireguard.nix
│   └── home/         # Service-related home configs
│
├── 04-applications/  # User applications (depends on services)
│   ├── system/       # System-level application configs
│   └── home/         # Home-manager applications
│       ├── vscode.nix
│       ├── alacritty.nix
│       └── zsh.nix
│
├── 05-bundles/       # Tool combinations (depends on applications)
│   └── tool-bundles/ # Existing tool bundles
│
└── 06-profiles/      # Complete environments (depends on bundles)
    └── profiles/     # Existing profiles
```

## Dependency Rules

**Golden Rule**: Higher layers can depend on lower layers, but never the reverse.

1. **Layer 1 (Core)**: No dependencies on other MaxOS modules
2. **Layer 2 (Hardware)**: Can depend on Layer 1 only
3. **Layer 3 (Services)**: Can depend on Layers 1-2
4. **Layer 4 (Applications)**: Can depend on Layers 1-3
5. **Layer 5 (Bundles)**: Can depend on Layers 1-4
6. **Layer 6 (Profiles)**: Can depend on Layers 1-5

## Context Separation

### System vs Home Modules

To prevent `osConfig` recursion issues, modules are strictly separated:

- **System modules** (`system/`): Only configure system-level options
- **Home modules** (`home/`): Only configure home-manager options
- **No hybrid modules**: Eliminated modules that try to work in both contexts

### Safe Module Pattern

All modules follow this template:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.MODULENAME;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true &&
    config.maxos.secrets.enable or true;
    
in {
  options.maxos.MODULENAME = {
    enable = mkEnableOption "MODULENAME";
    # Define ALL options you plan to use
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # Only set options that are:
    # 1. Defined in this module's options
    # 2. Standard NixOS options
    # 3. Lower-layer maxos options
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MODULENAME requires user and secrets modules";
      }
    ];
  };
}
```

## Key Changes

### Eliminated Recursion Sources

1. **Removed osConfig parameters**: No more `osConfig ? {}` in module signatures
2. **Separated contexts**: System and home modules are completely separate
3. **Explicit dependencies**: All dependencies are validated before use
4. **Consistent option namespaces**: All modules use `maxos.*` for system options

### Enhanced Validation

The new validation system (`validation-enhanced.nix`) provides:

- **Dependency graph validation**: Detects circular dependencies
- **Layer compliance checking**: Ensures modules only reference lower layers
- **Runtime dependency validation**: Checks tool dependencies (e.g., Kind requires Docker)
- **Comprehensive assertions**: Validates configuration consistency

## Migration Guide

### For Existing Configurations

1. **Backup your current setup**:
   ```bash
   cp -r modules modules.backup
   ```

2. **Update your flake.nix**:
   ```nix
   # Replace
   imports = [ ./modules ];
   
   # With
   imports = [ ./modules/default-layered.nix ];
   ```

3. **Test your configuration**:
   ```bash
   nix build .#nixosConfigurations.YOUR_HOST.config.system.build.toplevel
   ```

4. **Run the migration script**:
   ```bash
   ./scripts/migrate-to-layered-structure.sh
   ```

### For New Modules

1. **Use the safe module template**: `templates/safe-module.nix`
2. **Place in correct layer**: Follow the dependency rules
3. **Separate system/home concerns**: Create separate modules if needed
4. **Test in isolation**: Ensure module evaluates independently

## Testing

### Syntax Testing
```bash
# Test individual modules
nix-instantiate --eval --expr '
  let pkgs = import <nixpkgs> {}; lib = pkgs.lib; config = {};
  in (import ./modules/01-core/system/user.nix { inherit config lib pkgs; })
'

# Test layer imports
nix-instantiate --eval --expr '
  let pkgs = import <nixpkgs> {}; lib = pkgs.lib; config = {};
  in (import ./modules/system-layered.nix { inherit config lib pkgs; })
'
```

### Build Testing
```bash
# Test all host configurations
for host in G16 rig test; do
  echo "Testing $host..."
  nix build .#nixosConfigurations.$host.config.system.build.toplevel
done
```

### Validation Report
```bash
# Generate validation report
nix build .#nixosConfigurations.YOUR_HOST.config.system.build.moduleValidationReport
cat result
```

## Benefits

1. **Prevents infinite recursion**: Strict layering eliminates circular dependencies
2. **Clearer architecture**: Explicit dependency relationships
3. **Better maintainability**: Easier to understand and modify
4. **Enhanced validation**: Comprehensive error checking and reporting
5. **Future-proof**: Scalable architecture for new modules

## Troubleshooting

### Common Issues

1. **"Infinite recursion encountered"**:
   - Check for circular dependencies between modules
   - Ensure you're not referencing higher-layer options from lower layers
   - Verify no `osConfig` usage in modules

2. **"Option does not exist"**:
   - Ensure all referenced options are defined in the same or lower layers
   - Check that dependencies are properly enabled

3. **"Assertion failed"**:
   - Review dependency validation in your modules
   - Ensure required modules are enabled before dependent modules

### Debug Commands

```bash
# Show detailed evaluation trace
nix-instantiate --eval --show-trace --expr 'YOUR_EXPRESSION'

# Check specific module evaluation
nix-instantiate --eval --expr '
  let
    pkgs = import <nixpkgs> {};
    lib = pkgs.lib;
    config = { maxos.user.enable = true; };
  in
  (import ./modules/PATH_TO_MODULE { inherit config lib pkgs; })
'
```

This layered architecture ensures MaxOS remains maintainable and recursion-free while preserving its excellent modularity.