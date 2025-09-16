{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.packageBundles;
  commonPackages = import ./common-packages.nix { inherit pkgs; };
in
{
  options.maxos.packageBundles = {
    enable = mkEnableOption "package bundles";
    
    systemUtils = mkEnableOption "basic system utilities";
    devEssentials = mkEnableOption "development essentials";
    terminalUtils = mkEnableOption "terminal and shell utilities";
    networkTools = mkEnableOption "network and monitoring tools";
    commonFonts = mkEnableOption "common fonts";
    mediaTools = mkEnableOption "media and file management tools";
    desktopUtils = mkEnableOption "desktop utilities";
    communication = mkEnableOption "communication tools";
    productivity = mkEnableOption "office and productivity tools";
    pythonDev = mkEnableOption "Python development stack";
    javaDev = mkEnableOption "Java development stack";
    securityTools = mkEnableOption "security and pentesting tools";
    sysAdmin = mkEnableOption "system administration tools";
    containerTools = mkEnableOption "container and orchestration tools";
    
    # Predefined bundles
    desktopBundle = mkEnableOption "complete desktop bundle";
    developmentBundle = mkEnableOption "development workstation bundle";
    serverBundle = mkEnableOption "server administration bundle";
    securityBundle = mkEnableOption "security focused bundle";
    
    # Installation target
    installTarget = mkOption {
      type = types.enum [ "system" "home" "both" ];
      default = "system";
      description = "Where to install packages: system, home-manager, or both";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # System packages
    (mkIf (cfg.installTarget == "system" || cfg.installTarget == "both") {
      environment.systemPackages = with commonPackages; mkMerge [
        (mkIf cfg.systemUtils systemUtils)
        (mkIf cfg.devEssentials devEssentials)
        (mkIf cfg.terminalUtils terminalUtils)
        (mkIf cfg.networkTools networkTools)
        (mkIf cfg.commonFonts commonFonts)
        (mkIf cfg.mediaTools mediaTools)
        (mkIf cfg.desktopUtils desktopUtils)
        (mkIf cfg.communication communication)
        (mkIf cfg.productivity productivity)
        (mkIf cfg.pythonDev pythonDev)
        (mkIf cfg.javaDev javaDev)
        (mkIf cfg.securityTools securityTools)
        (mkIf cfg.sysAdmin sysAdmin)
        (mkIf cfg.containerTools containerTools)
        
        # Predefined bundles
        (mkIf cfg.desktopBundle desktopBundle)
        (mkIf cfg.developmentBundle developmentBundle)
        (mkIf cfg.serverBundle serverBundle)
        (mkIf cfg.securityBundle securityBundle)
      ];
    })
    
    # Home Manager packages (when in Home Manager context)
    (mkIf (cfg.installTarget == "home" || cfg.installTarget == "both") {
      home.packages = with commonPackages; mkMerge [
        (mkIf cfg.systemUtils systemUtils)
        (mkIf cfg.devEssentials devEssentials)
        (mkIf cfg.terminalUtils terminalUtils)
        (mkIf cfg.networkTools networkTools) 
        (mkIf cfg.commonFonts commonFonts)
        (mkIf cfg.mediaTools mediaTools)
        (mkIf cfg.desktopUtils desktopUtils)
        (mkIf cfg.communication communication)
        (mkIf cfg.productivity productivity)
        (mkIf cfg.pythonDev pythonDev)
        (mkIf cfg.javaDev javaDev)
        (mkIf cfg.securityTools securityTools)
        (mkIf cfg.sysAdmin sysAdmin)
        (mkIf cfg.containerTools containerTools)
        
        # Predefined bundles
        (mkIf cfg.desktopBundle desktopBundle)
        (mkIf cfg.developmentBundle developmentBundle) 
        (mkIf cfg.serverBundle serverBundle)
        (mkIf cfg.securityBundle securityBundle)
      ];
    })
  ]);
}