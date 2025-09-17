# Enhanced Module Validation System for MaxOS
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.validation;
  
  # Define module dependency graph
  dependencyGraph = {
    # Layer 1: Core (no dependencies)
    "01-core" = {
      order = 1;
      dependencies = [];
      modules = [ "user" "secrets" "fonts" ];
    };
    
    # Layer 2: Hardware (depends on core)
    "02-hardware" = {
      order = 2;
      dependencies = [ "01-core" ];
      modules = [ "laptop" "desktop" "server" ];
    };
    
    # Layer 3: Services (depends on core + hardware)
    "03-services" = {
      order = 3;
      dependencies = [ "01-core" "02-hardware" ];
      modules = [ "docker" "k3s" "wireguard" ];
    };
    
    # Layer 4: Applications (depends on services)
    "04-applications" = {
      order = 4;
      dependencies = [ "01-core" "02-hardware" "03-services" ];
      modules = [ "vscode" "alacritty" "zsh" ];
    };
    
    # Layer 5: Bundles (depends on applications)
    "05-bundles" = {
      order = 5;
      dependencies = [ "01-core" "02-hardware" "03-services" "04-applications" ];
      modules = [ "development" "security" "gaming" ];
    };
    
    # Layer 6: Profiles (depends on bundles)
    "06-profiles" = {
      order = 6;
      dependencies = [ "01-core" "02-hardware" "03-services" "04-applications" "05-bundles" ];
      modules = [ "gaming-workstation" "developer-workstation" "home-server" ];
    };
  };
  
  # Validate dependency graph for cycles
  validateDependencyGraph = graph:
    let
      # Check for circular dependencies using topological sort
      layers = attrNames graph;
      
      # Verify each layer only depends on lower-order layers
      layerChecks = map (layerName:
        let
          layer = graph.${layerName};
          dependencyOrders = map (dep: graph.${dep}.order) layer.dependencies;
          maxDepOrder = if dependencyOrders == [] then 0 else builtins.foldl' max 0 dependencyOrders;
        in maxDepOrder < layer.order
      ) layers;
      
    in builtins.all (x: x) layerChecks;
  
  # Check if a module follows naming conventions
  validateModuleNaming = moduleName: moduleType:
    let
      expectedPrefix = if moduleType == "system" then "maxos" else "maxos.tools";
    in hasPrefix expectedPrefix moduleName;
  
  # Runtime dependency validation
  validateRuntimeDependencies = config:
    let
      # Check Docker -> Kind dependency
      dockerEnabled = config.maxos.tools.docker.enable or false;
      kindEnabled = config.maxos.tools.kind.enable or false;
      
      # Check hardware exclusivity
      hardwareTypes = [
        (config.maxos.hardware.laptop.enable or false)
        (config.maxos.hardware.desktop.enable or false)
        (config.maxos.hardware.server.enable or false)
      ];
      multipleHardware = (length (filter (x: x) hardwareTypes)) > 1;
      
    in [
      {
        assertion = !kindEnabled || dockerEnabled;
        message = "Kind requires Docker to be enabled";
      }
      {
        assertion = !multipleHardware;
        message = "Only one hardware type can be enabled at a time";
      }
    ];
    
in {
  options.maxos.validation = {
    enable = mkEnableOption "enhanced module validation" // { default = true; };
    
    enableRecursionChecks = mkOption {
      type = types.bool;
      default = true;
      description = "Enable recursion detection and prevention";
    };
    
    strictMode = mkOption {
      type = types.bool;
      default = false;
      description = "Enable strict validation that fails builds on invalid modules";
    };
    
    generateReport = mkOption {
      type = types.bool;
      default = false;
      description = "Generate validation report during build";
    };
    
    dependencyGraph = mkOption {
      type = types.attrs;
      default = dependencyGraph;
      description = "Module dependency graph for validation";
    };
  };
  
  config = mkIf cfg.enable {
    assertions = if cfg.strictMode then
      [
        {
          assertion = validateDependencyGraph cfg.dependencyGraph;
          message = "Circular dependency detected in module graph";
        }
        
        # User configuration validation
        {
          assertion = config.maxos.user.name != "";
          message = "maxos.user.name cannot be empty";
        }
        {
          assertion = config.maxos.user.homeDirectory != "";
          message = "maxos.user.homeDirectory must be specified";
        }
        {
          assertion = hasPrefix "/home/" config.maxos.user.homeDirectory;
          message = "maxos.user.homeDirectory should start with /home/";
        }
        
        # Hostname validation
        {
          assertion = config.networking.hostName != "";
          message = "networking.hostName cannot be empty";
        }
        {
          assertion = stringLength config.networking.hostName <= 63;
          message = "networking.hostName must be 63 characters or less";
        }
        {
          assertion = !(hasInfix "." config.networking.hostName);
          message = "networking.hostName should not contain dots";
        }
      ] ++ (validateRuntimeDependencies config)
    else [];
    
    # Add warnings for common module issues
    warnings = let
      dependencyWarnings = [
        (optionalString (config.maxos.tools.kind.enable or false &&
                        !(config.maxos.tools.docker.enable or false))
          "Kind is enabled but Docker is not - Kind requires Docker to function properly")
        
        (optionalString (config.maxos.hardware.laptop.enable or false && 
                        !(config.maxos.hardware.laptop.powerManagement.enable or true))
          "Power management is disabled on laptop - this may impact battery life")
        
        (optionalString (config.modules.toolBundles.gaming.enable or false && 
                        !(config.maxos.hardware.desktop.graphics.nvidia or false || 
                          config.maxos.hardware.desktop.graphics.amd or false))
          "Gaming bundle is enabled but no dedicated GPU is configured")
      ];
      
    in filter (w: w != "") dependencyWarnings;
    
    # Generate validation report if requested
    system.build.moduleValidationReport = mkIf cfg.generateReport (
      pkgs.writeText "enhanced-module-validation-report" ''
        MaxOS Enhanced Module Validation Report
        =====================================
        
        Dependency Graph Validation: ${if validateDependencyGraph cfg.dependencyGraph then "PASSED" else "FAILED"}
        
        Layer Structure:
        ${concatStringsSep "\n" (mapAttrsToList (name: layer: 
          "  ${name} (order ${toString layer.order}): ${concatStringsSep ", " layer.modules}"
        ) cfg.dependencyGraph)}
        
        Dependency Relationships:
        ${concatStringsSep "\n" (mapAttrsToList (name: layer:
          if layer.dependencies != [] then
            "  ${name} depends on: ${concatStringsSep ", " layer.dependencies}"
          else
            "  ${name} has no dependencies"
        ) cfg.dependencyGraph)}
        
        Validation Status: ${if cfg.strictMode then "STRICT MODE" else "PERMISSIVE MODE"}
        Recursion Checks: ${if cfg.enableRecursionChecks then "ENABLED" else "DISABLED"}
      ''
    );
  };
}