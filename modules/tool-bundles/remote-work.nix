{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.remoteWork;
in {
  options.modules.toolBundles.remoteWork = {
    enable = mkEnableOption "Remote work tools bundle";
    
    profile = mkOption {
      type = types.enum [ "basic" "enhanced" "secure" ];
      default = "enhanced";
      description = "Remote work profile level";
    };
    
    enableRemoteAccess = mkOption {
      type = types.bool;
      default = true;
      description = "Enable remote desktop and access tools";
    };
    
    enableSecureConnectivity = mkOption {
      type = types.bool;
      default = cfg.profile == "secure" || cfg.profile == "enhanced";
      description = "Enable secure networking (VPN, SSH)";
    };
    
    enableCollaboration = mkOption {
      type = types.bool;
      default = cfg.profile != "basic";
      description = "Enable collaboration and communication tools";
    };
    
    enableFilesync = mkOption {
      type = types.bool;
      default = true;
      description = "Enable file synchronization";
    };
  };

  config = mkIf cfg.enable {
    modules.tools = {
      # Remote access
      remmina.enable = mkIf cfg.enableRemoteAccess true;
      sshfs.enable = mkIf cfg.enableRemoteAccess true;
      mosh.enable = mkIf cfg.enableRemoteAccess true;
      
      # Secure connectivity
      wireguard.enable = mkIf cfg.enableSecureConnectivity true;
      
      # Communication and collaboration
      whatsapp-mcp.enable = mkIf cfg.enableCollaboration true;
      
      # File synchronization and productivity
      syncthing.enable = mkIf cfg.enableFilesync true;
      logseq.enable = mkIf cfg.enableCollaboration true;
      
      # Essential tools for all profiles
      keepassxc.enable = true;
      chromium.enable = true;
    };
  };
}