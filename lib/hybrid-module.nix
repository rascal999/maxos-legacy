# Helper functions for creating hybrid modules
{ lib }:

let
  inherit (lib) mkOption mkEnableOption mkIf mkMerge types optionals;
  
  # Create a hybrid module that works in both system and home-manager contexts
  mkHybridModule = {
    name,
    description ? "${name} hybrid module",
    systemPackages ? [],
    homePackages ? [],
    systemConfig ? {},
    homeConfig ? {},
    systemServices ? {},
    homePrograms ? {},
    options ? {},
    dependencies ? []
  }: 
  { config, lib, pkgs, osConfig ? {}, ... }:
  
  let
    cfg = config.modules.tools.${name};
    # Detect if we're in home-manager context
    isHomeManager = osConfig != {};
    # Get unified user config
    userConfig = if isHomeManager then osConfig.maxos.user else config.maxos.user;
    
    # Default options that all hybrid modules should have
    defaultOptions = {
      enable = mkEnableOption description;
    };
    
    # Merge user-provided options with defaults
    allOptions = defaultOptions // options;
    
  in {
    options.modules.tools.${name} = allOptions;
    
    config = mkIf cfg.enable (mkMerge [
      # Home-manager configuration
      (mkIf isHomeManager (mkMerge [
        {
          home.packages = homePackages;
          programs = homePrograms;
        }
        homeConfig
      ]))
      
      # System-level configuration
      (mkIf (!isHomeManager) (mkMerge [
        {
          environment.systemPackages = systemPackages;
          systemd.services = systemServices;
        }
        systemConfig
      ]))
    ]);
  };

  # Quick hybrid module for simple tools that just need packages
  mkSimpleHybrid = { name, description ? "${name} tool", packages ? [], homeOnly ? false }:
    mkHybridModule {
      inherit name description;
      systemPackages = if homeOnly then [] else packages;
      homePackages = packages;
    };

  # Hybrid module for development tools with common patterns
  mkDevHybrid = { name, description, packages ? [], shellAliases ? {}, environmentVariables ? {} }:
    mkHybridModule {
      inherit name description;
      systemPackages = packages;
      homePackages = packages;
      
      homeConfig = mkIf (shellAliases != {} || environmentVariables != {}) {
        programs.bash.shellAliases = shellAliases;
        programs.zsh.shellAliases = shellAliases;
        home.sessionVariables = environmentVariables;
      };
      
      systemConfig = mkIf (environmentVariables != {}) {
        environment.variables = environmentVariables;
      };
    };

in {
  inherit mkHybridModule mkSimpleHybrid mkDevHybrid;
}