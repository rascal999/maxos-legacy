# Dynamic Module Discovery System
{ lib }:

let
  inherit (lib) filterAttrs mapAttrs' nameValuePair hasPrefix hasSuffix removeSuffix;
  
  # Recursively discover .nix files in a directory
  discoverNixFiles = dir:
    let
      entries = builtins.readDir dir;
      
      nixFiles = filterAttrs (name: type: 
        type == "regular" && hasSuffix ".nix" name && !hasPrefix "default" name
      ) entries;
      
      subDirectories = filterAttrs (name: type: type == "directory") entries;
      
      # Convert .nix files to module imports
      fileModules = mapAttrs' (name: _: 
        nameValuePair (removeSuffix ".nix" name) (dir + "/${name}")
      ) nixFiles;
      
      # Recursively process subdirectories with default.nix
      dirModules = mapAttrs' (name: _:
        let subdir = dir + "/${name}";
        in if builtins.pathExists (subdir + "/default.nix")
           then nameValuePair name (subdir + "/default.nix")
           else nameValuePair name null
      ) subDirectories;
      
    in fileModules // (filterAttrs (_: v: v != null) dirModules);

  # Generate module imports list from discovered modules
  generateImports = modules:
    builtins.attrValues modules;

  # Validate that a module follows MaxOS conventions
  validateModule = path: moduleName:
    let
      module = import path;
      # Basic validation - could be expanded
      isValidModule = builtins.isFunction module;
    in {
      name = moduleName;
      path = path;
      valid = isValidModule;
    };

  # Auto-discover and validate modules in a directory
  discoverAndValidateModules = dir:
    let
      discovered = discoverNixFiles dir;
      validated = mapAttrs' (name: path: 
        nameValuePair name (validateModule path name)
      ) discovered;
    in validated;

in {
  inherit discoverNixFiles generateImports validateModule discoverAndValidateModules;
  
  # Convenience function for tool modules
  discoverToolModules = toolsDir:
    let discovered = discoverNixFiles toolsDir;
    in generateImports discovered;
}