{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.sharedUser;
in
{
  options.maxos.sharedUser = {
    enable = mkEnableOption "shared user configuration";
    
    username = mkOption {
      type = types.str;
      default = "user";
      description = "The username for the primary user";
    };
    
    initialPassword = mkOption {
      type = types.str;
      default = "nixos";
      description = "Initial password for the user";
    };
    
    shell = mkOption {
      type = types.package;
      default = pkgs.zsh;
      description = "Default shell for the user";
    };
    
    extraGroups = mkOption {
      type = types.listOf types.str;
      default = [ "wheel" "networkmanager" "video" "audio" "docker" ];
      description = "Additional groups for the user";
    };
    
    enableDisplayManager = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable display manager configuration";
    };
    
    displayManager = mkOption {
      type = types.enum [ "lightdm" "gdm" "sddm" ];
      default = "lightdm";
      description = "Which display manager to use";
    };
    
    desktopEnvironment = mkOption {
      type = types.enum [ "xfce" "gnome" "kde" "i3" ];
      default = "xfce";
      description = "Which desktop environment to use";
    };
  };

  config = mkIf cfg.enable {
    users = {
      mutableUsers = true;
      users.${cfg.username} = {
        isNormalUser = true;
        group = "users";
        extraGroups = cfg.extraGroups;
        initialPassword = cfg.initialPassword;
        createHome = true;
        home = "/home/${cfg.username}";
        shell = cfg.shell;
      };
    };

    # Display manager configuration
    services.xserver = mkIf cfg.enableDisplayManager {
      enable = true;
      displayManager = mkMerge [
        (mkIf (cfg.displayManager == "lightdm") { lightdm.enable = true; })
        (mkIf (cfg.displayManager == "gdm") { gdm.enable = true; })
        (mkIf (cfg.displayManager == "sddm") { sddm.enable = true; })
      ];
      desktopManager = mkMerge [
        (mkIf (cfg.desktopEnvironment == "xfce") { xfce.enable = true; })
        (mkIf (cfg.desktopEnvironment == "gnome") { gnome.enable = true; })
        (mkIf (cfg.desktopEnvironment == "kde") { plasma5.enable = true; })
      ];
    };

    # Enable i3 if specified
    services.xserver.windowManager.i3.enable = mkIf (cfg.desktopEnvironment == "i3") true;
  };
}