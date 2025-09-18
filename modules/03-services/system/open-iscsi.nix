{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.open-iscsi;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.open-iscsi = {
    enable = mkEnableOption "Open-iSCSI initiator for connecting to iSCSI targets";
    
    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically start the open-iscsi service";
    };
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration to add to iscsid.conf";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS open-iscsi requires user module to be enabled";
      }
    ];

    # Enable the open-iscsi service
    services.openiscsi = {
      enable = true;
      name = "iqn.2024-05.nixos:${config.networking.hostName}";
    };
    
    # Add open-iscsi tools to system packages
    environment.systemPackages = with pkgs; [
      openiscsi  # Provides iscsiadm and other iSCSI tools
    ];
    
    # Configure systemd service to start automatically if requested
    systemd.services.iscsid = mkIf cfg.autoStart {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
    
    # Additional configuration file if specified
    environment.etc."iscsi/iscsid.conf" = mkIf (cfg.extraConfig != "") {
      text = cfg.extraConfig;
      mode = "0600";
    };
    
    # Load required kernel modules
    boot.kernelModules = [ "iscsi_tcp" ];
  };
}