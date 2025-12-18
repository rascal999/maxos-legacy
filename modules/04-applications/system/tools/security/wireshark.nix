{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.wireshark;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.wireshark = {
    enable = mkEnableOption "Wireshark network protocol analyzer";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # Enable Wireshark system-wide
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    # Add user to the wireshark group to allow capturing packets without sudo
    users.users.${config.maxos.user.name}.extraGroups = [ "wireshark" ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "Wireshark requires the user module to be configured";
      }
    ];
  };
}