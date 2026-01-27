{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.mitmproxy;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.mitmproxy = {
    enable = mkEnableOption "mitmproxy - an interactive HTTPS proxy";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      mitmproxy
    ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "mitmproxy requires the user module to be configured";
      }
    ];
  };
}
