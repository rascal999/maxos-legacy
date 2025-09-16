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
      # System-level remote tools
      wireguard.enable = mkIf cfg.enableSecureConnectivity true;
      whatsapp-mcp.enable = mkIf cfg.enableCollaboration true;
      # Note: syncthing needs proper module format
      # syncthing.enable = mkIf cfg.enableFilesync true;
      
      # Note: The following are handled via home-manager:
      # - Remote access: remmina, sshfs, mosh (home-manager modules)
      # - Productivity: logseq (home-manager module)
      
      # Essential tools for all profiles
      keepassxc.enable = true;
      chromium.enable = true;
    };
  };
}