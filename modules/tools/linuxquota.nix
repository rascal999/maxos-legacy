{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.linuxquota;
in {
  options.modules.tools.linuxquota = {
    enable = mkEnableOption "Linux quota tools for disk quota management";
    
    enableUserQuotas = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable user quotas";
    };
    
    enableGroupQuotas = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable group quotas";
    };
  };

  config = mkIf cfg.enable {
    # Install quota tools
    environment.systemPackages = with pkgs; [
      quota
    ];

    # Configure quota options
    boot.kernelModules = [ "quota_v2" ];
    
    # Note: Filesystem quota options need to be configured manually
    # in the specific filesystem configuration where quotas are needed.
    # Example for root filesystem:
    # fileSystems."/" = {
    #   options = [ "usrquota" "grpquota" ];
    # };
  };
}