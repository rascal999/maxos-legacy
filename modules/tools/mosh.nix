{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.mosh;
in {
  options.modules.tools.mosh = {
    enable = mkEnableOption "Mosh (mobile shell) support";
    
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open firewall ports for Mosh (UDP 60000-61000)";
    };
    
    serverPort = mkOption {
      type = types.int;
      default = 22;
      description = "SSH port that Mosh server will use to establish initial connection";
    };
  };

  config = mkIf cfg.enable {
    # Install Mosh package
    environment.systemPackages = with pkgs; [
      mosh
    ];

    # Open firewall ports for Mosh if requested
    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; }  # Mosh uses UDP ports in this range
      ];
    };

    # Ensure SSH is available (Mosh requires SSH for initial connection)
    services.openssh.enable = mkDefault true;
  };
}