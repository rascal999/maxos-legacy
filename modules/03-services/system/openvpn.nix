{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.openvpn;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true; # OpenVPN has no hard dependencies
  
in {
  options.maxos.tools.openvpn = {
    enable = mkEnableOption "OpenVPN client and tools";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # Install OpenVPN client package
    environment.systemPackages = with pkgs; [
      openvpn
    ];
    
    # Enable OpenVPN service (allows using systemd service management)
    services.openvpn = {
      servers = {
        # Placeholder for VPN configurations
        # Users can add specific configurations in their host files
      };
    };
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "OpenVPN has no hard dependencies";
      }
    ];
  };
}