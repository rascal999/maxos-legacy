{ config, lib, pkgs, ... }:

# This module enables and configures Skaffold.
# Skaffold is a command line tool that facilitates continuous development for Kubernetes applications.

with lib;

let
  cfg = config.modules.tools.skaffold;
in {
  options.modules.tools.skaffold = {
    enable = mkEnableOption "Skaffold";
    
    defaultRepo = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default repository for Skaffold to push images to";
    };
    
    enablePortForward = mkOption {
      type = types.bool;
      default = true;
      description = "Enable port forwarding by default";
    };
    
    enableFileSyncMode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable file sync mode for faster development";
    };
    
    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "Extra configuration for Skaffold (YAML format)";
    };
  };

  config = mkIf cfg.enable {
    # Install Skaffold
    environment.systemPackages = with pkgs; [
      skaffold
      # Ensure kubectl and docker are available for Skaffold
      kubectl
      docker
      # Additional tools that work well with Skaffold
      kubernetes-helm
      kustomize
    ];

    # Ensure Docker is enabled (Skaffold requires Docker for building images)
    virtualisation.docker.enable = true;
    
    # Add user to docker group for Skaffold access
    users.users.user.extraGroups = [ "docker" ];
    
    # Create global Skaffold configuration if specified
    environment.etc = mkIf (cfg.extraConfig != "") {
      "skaffold/config".text = cfg.extraConfig;
    };
    
    # Set up environment variables for Skaffold
    environment.variables = mkMerge [
      (mkIf (cfg.defaultRepo != null) {
        SKAFFOLD_DEFAULT_REPO = cfg.defaultRepo;
      })
      {
        # Enable Skaffold's update check (can be disabled by setting to false)
        SKAFFOLD_UPDATE_CHECK = "true";
        # Set cache directory
        SKAFFOLD_CACHE_DIR = "/tmp/skaffold-cache";
      }
    ];
    
    # Create a systemd service to ensure Skaffold cache directory exists
    systemd.tmpfiles.rules = [
      "d /tmp/skaffold-cache 0755 user users -"
    ];
  };
}