# Preventing Infinite Recursion in MaxOS

This guide outlines architectural patterns and design principles to prevent infinite recursion issues in the MaxOS NixOS configuration system.

## Understanding Recursion in NixOS

Infinite recursion occurs when the Nix evaluator encounters circular dependencies during module evaluation. This happens before any code execution - it's a pure evaluation-time issue.

## Root Causes of Recursion

### 1. Undefined Option References
```nix
# ❌ WRONG: Setting undefined options
config = {
  maxos.fontConfig = cfg.primary;  # maxos.fontConfig not defined anywhere
};

# ✅ CORRECT: Define options first
options.maxos.fontConfig = mkOption { ... };
config = mkIf cfg.enable {
  maxos.fontConfig = cfg.primary;
};
```

### 2. Circular Module Dependencies
```nix
# ❌ WRONG: Module A imports Module B, Module B imports Module A
# modules/a.nix
imports = [ ./b.nix ];

# modules/b.nix  
imports = [ ./a.nix ];
```

### 3. osConfig Loops in Home-Manager
```nix
# ❌ WRONG: Home-manager module accessing system config that references home config
{ config, osConfig, ... }:
let
  userConfig = osConfig.maxos.user;  # Creates loop if system references home
in { ... }
```

### 4. Cross-Context Option Access
```nix
# ❌ WRONG: System module trying to set home-manager options
config = {
  home-manager.users.user.environment = { ... };  # Invalid option path
};
```

## Prevention Strategies

### 1. Layered Architecture

Organize modules in clear dependency layers:

```
Layer 1: Core (no dependencies)
├── user.nix
├── secrets.nix
└── fonts.nix

Layer 2: Hardware (depends on core)
├── laptop.nix
├── desktop.nix
└── server.nix

Layer 3: Tools (depends on core + hardware)
├── docker.nix
├── vscode.nix
└── i3.nix

Layer 4: Bundles (depends on tools)
├── development.nix
├── security.nix
└── gaming.nix

Layer 5: Profiles (depends on bundles)
├── gaming-workstation.nix
└── developer-workstation.nix
```

**Rule**: Higher layers can depend on lower layers, but never the reverse.

### 2. Strict Option Definition Pattern

```nix
# Template for recursion-safe modules
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.moduleName;
in {
  # 1. ALWAYS define options first
  options.maxos.moduleName = {
    enable = mkEnableOption "module description";
    # ... other options
  };

  # 2. ONLY set options you've defined
  config = mkIf cfg.enable {
    # Only reference:
    # - cfg.* (your own options)
    # - Standard NixOS options
    # - Lower-layer maxos options
  };
}
```

### 3. Context Separation

**Separate System and Home Modules:**
```
modules/
├── system/           # System-only modules
│   ├── docker.nix
│   └── fonts.nix
└── home/            # Home-manager only modules
    ├── vscode.nix
    └── alacritty.nix
```

**Avoid Hybrid Modules:**
```nix
# ❌ AVOID: Hybrid modules with osConfig
{ config, osConfig ? {}, ... }:

# ✅ PREFER: Separate modules
# system/docker.nix - system configuration only
# home/docker.nix - home-manager configuration only
```

### 4. Dependency Injection Pattern

**Pass data through specialArgs instead of cross-module references:**

```nix
# flake.nix
nixosSystem {
  specialArgs = {
    userConfig = {
      name = "user";
      homeDirectory = "/home/user";
    };
  };
  modules = [ ... ];
}

# modules receive userConfig as parameter
{ config, lib, pkgs, userConfig, ... }:
```

### 5. Lazy Evaluation Guards

```nix
# Use mkDefault for potentially circular references
config = mkIf cfg.enable {
  someOption = mkDefault (
    if config.other.module.enable 
    then "value1" 
    else "value2"
  );
};
```

### 6. Module Registry System

**Implement explicit dependency management:**

```nix
# lib/module-registry.nix
{
  core = {
    order = 1;
    modules = [ "user" "secrets" "fonts" ];
  };
  hardware = {
    order = 2;
    dependencies = [ "core" ];
    modules = [ "laptop" "desktop" "server" ];
  };
  tools = {
    order = 3;
    dependencies = [ "core" "hardware" ];
    modules = [ "docker" "vscode" "i3" ];
  };
}
```

## Testing for Recursion

### 1. Incremental Testing
```bash
# Test individual modules
nix-instantiate --eval --expr '(import ./modules/core/fonts.nix)'

# Test module combinations
nix-instantiate --eval --expr '
  let
    pkgs = import <nixpkgs> {};
    lib = pkgs.lib;
    config = {};
  in
  (import ./modules/core/fonts.nix { inherit config lib pkgs; })
'
```

### 2. Dependency Validation
```nix
# Add to each module
config = {
  assertions = [
    {
      assertion = !config.maxos.moduleName.enable || config.maxos.dependency.enable;
      message = "moduleName requires dependency to be enabled";
    }
  ];
};
```

### 3. Build Testing Pipeline
```bash
# Test all host configurations
for host in G16 rig test; do
  echo "Testing $host..."
  nix build .#nixosConfigurations.$host.config.system.build.toplevel
done
```

## MaxOS-Specific Recommendations

### 1. Restructure Module Hierarchy

```
modules/
├── 01-core/          # Foundation layer (no dependencies)
│   ├── user.nix
│   ├── secrets.nix
│   └── fonts.nix
├── 02-hardware/      # Hardware abstraction (depends on core)
│   ├── laptop.nix
│   └── desktop.nix
├── 03-services/      # System services (depends on core+hardware)
│   ├── docker.nix
│   └── k3s.nix
├── 04-applications/  # User applications (depends on services)
│   ├── vscode.nix
│   └── browsers.nix
├── 05-bundles/       # Tool combinations (depends on applications)
│   ├── development.nix
│   └── security.nix
└── 06-profiles/      # Complete environments (depends on bundles)
    ├── gaming-workstation.nix
    └── developer-workstation.nix
```

### 2. Implement Validation System

```nix
# modules/core/validation-enhanced.nix
{
  options.maxos.validation = {
    enableRecursionChecks = mkEnableOption "recursion detection";
    dependencyGraph = mkOption {
      type = types.attrs;
      description = "Module dependency graph for validation";
    };
  };
  
  config = mkIf config.maxos.validation.enableRecursionChecks {
    assertions = [
      {
        assertion = validateDependencyGraph config.maxos.validation.dependencyGraph;
        message = "Circular dependency detected in module graph";
      }
    ];
  };
}
```

### 3. Safe Module Template

```nix
# templates/safe-module.nix
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

### 4. Development Workflow

**Before adding new modules:**
1. **Map dependencies** - what does this module need?
2. **Check layer compliance** - is it in the right layer?
3. **Test in isolation** - does the module evaluate alone?
4. **Test incrementally** - add to system gradually

**When recursion occurs:**
1. **Identify the cycle** using `--show-trace`
2. **Check option definitions** - are you setting undefined options?
3. **Validate layer compliance** - are you referencing higher layers?
4. **Use lazy evaluation** with `mkDefault` if needed

This architectural approach will prevent future recursion issues while maintaining MaxOS's excellent modularity.