{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.crane;
  
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.crane = {
    enable = mkEnableOption "crane OCI image puller and pusher";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      crane
    ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "crane requires user module";
      }
    ];
  };
}
