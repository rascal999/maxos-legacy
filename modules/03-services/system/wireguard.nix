{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.wireguard;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true; # WireGuard has no hard dependencies
  
in {
  options.maxos.tools.wireguard = {
    enable = mkEnableOption "WireGuard VPN tools";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      wireguard-tools
    ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "WireGuard has no hard dependencies";
      }
    ];
  };
}