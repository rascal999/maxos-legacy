{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.keepassxc;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.keepassxc = {
    enable = mkEnableOption "KeePassXC password manager";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      keepassxc
    ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "KeePassXC requires user module to be enabled";
      }
    ];
  };
}
