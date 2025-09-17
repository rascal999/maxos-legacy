{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.mosh;
in {
  options.maxos.tools.mosh = {
    enable = mkEnableOption "Mosh (mobile shell) support";
    
    enableServer = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the Mosh server";
    };
    
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

    # Enable Mosh server if requested
    programs.mosh = mkIf cfg.enableServer {
      enable = true;
      withUtempter = true;  # Enable utempter support for proper session tracking
    };

    # Open firewall ports for Mosh if requested
    networking.firewall = mkIf cfg.openFirewall {
      allowedUDPPortRanges = [
        { from = 60000; to = 61000; }  # Mosh uses UDP ports in this range
      ];
    };

    # Note: SSH server configuration is handled by modules/security/ssh.nix
    # Mosh requires SSH for initial connection, which is enabled through the security module
  };
}