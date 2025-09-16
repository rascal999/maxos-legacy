{ lib }:

with lib;

rec {
  # Generate a simple tool module with just package installation
  generateSimpleTool = { toolName, packages, description ? null, systemPackages ? true, homePackages ? false, extraConfig ? {} }:
    { config, lib, pkgs, osConfig ? {}, ... }:
    
    let
      cfg = config.modules.tools.${toolName};
      isHomeManager = osConfig != {} && osConfig ? maxos && !(config ? nixpkgs);
    in {
      options.modules.tools.${toolName} = {
        enable = mkEnableOption (description or "${toolName} tool");
      };

      config = mkIf cfg.enable (mkMerge [
        # System packages
        (mkIf (systemPackages && !isHomeManager) {
          environment.systemPackages = packages pkgs;
        })
        
        # Home Manager packages
        (mkIf (homePackages && isHomeManager) {
          home.packages = packages pkgs;
        })
        
        # Extra configuration
        extraConfig
      ]);
    };

  # Generate a tool module with systemd service
  generateServiceTool = { toolName, packages, serviceName ? toolName, serviceConfig, description ? null, extraConfig ? {} }:
    { config, lib, pkgs, ... }:
    
    let
      cfg = config.modules.tools.${toolName};
    in {
      options.modules.tools.${toolName} = {
        enable = mkEnableOption (description or "${toolName} service tool");
      };

      config = mkIf cfg.enable (mkMerge [
        {
          environment.systemPackages = packages pkgs;
          systemd.services.${serviceName} = serviceConfig;
        }
        extraConfig
      ]);
    };

  # Generate a hybrid tool module (works in both NixOS and Home Manager)
  generateHybridTool = { toolName, packages, homeConfig ? {}, systemConfig ? {}, sharedConfig ? {}, description ? null }:
    { config, lib, pkgs, osConfig ? {}, ... }:
    
    let
      cfg = config.modules.tools.${toolName};
      isHomeManager = osConfig != {} && osConfig ? maxos && !(config ? nixpkgs);
    in {
      options.modules.tools.${toolName} = {
        enable = mkEnableOption (description or "${toolName} hybrid tool");
      };

      config = mkIf cfg.enable (mkMerge ([
        # Shared configuration
        sharedConfig
        
        # Home Manager specific
        (mkIf isHomeManager (mkMerge [
          { home.packages = packages pkgs; }
          homeConfig
        ]))
        
        # NixOS system specific  
        (mkIf (!isHomeManager) (mkMerge [
          { environment.systemPackages = packages pkgs; }
          systemConfig
        ]))
      ]));
    };

  # Generate a development tool with shell integration
  generateDevTool = { toolName, packages, shellInit ? "", aliases ? {}, envVars ? {}, description ? null }:
    generateHybridTool {
      inherit toolName packages description;
      homeConfig = {
        programs.zsh.initExtra = mkIf (shellInit != "") shellInit;
        programs.bash.initExtra = mkIf (shellInit != "") shellInit;
        programs.zsh.shellAliases = aliases;
        programs.bash.shellAliases = aliases;
        home.sessionVariables = envVars;
      };
      systemConfig = {
        environment.variables = envVars;
      };
    };
}