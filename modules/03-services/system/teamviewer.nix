{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.teamviewer;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.teamviewer = {
    enable = mkEnableOption "TeamViewer remote desktop and support";
    
    package = mkOption {
      type = types.package;
      default = pkgs.teamviewer;
      description = "TeamViewer package to use";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # Enable TeamViewer service
    services.teamviewer.enable = true;
    
    # Add TeamViewer to system packages
    environment.systemPackages = [ cfg.package ];
    
    # Ensure required networking ports are accessible
    # TeamViewer uses ports 5938 (TCP/UDP) and 443 (TCP)
    networking.firewall = {
      allowedTCPPorts = [ 5938 ];
      allowedUDPPorts = [ 5938 ];
    };
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "TeamViewer requires user module to be enabled";
      }
    ];
    
    warnings = [
      (optionalString (cfg.enable && !config.services.xserver.enable)
        "TeamViewer works best with a graphical environment (X11) enabled")
    ];
  };
}