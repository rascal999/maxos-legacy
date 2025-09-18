{ config, lib, pkgs, ... }:

# MaxOS Helmfile Tool Module (Layer 4 - Applications)
#
# This module provides the Helmfile deployment tool for managing multiple
# Helm charts as a single declarative unit, following layered architecture.

with lib;

let
  cfg = config.maxos.tools.helmfile;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.helmfile = {
    enable = mkEnableOption "Helmfile declarative Helm chart deployment tool";
    
    enableDiff = mkOption {
      type = types.bool;
      default = true;
      description = "Enable helm-diff plugin for better deployment previews";
    };
    
    enableSecrets = mkOption {
      type = types.bool;
      default = true;
      description = "Enable helm-secrets plugin for encrypted values support";
    };
    
    enableGit = mkOption {
      type = types.bool;
      default = true;
      description = "Enable helm-git plugin for Git-based chart repositories";
    };
    
    extraPlugins = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional Helm plugins to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS helmfile tool requires user module to be enabled";
      }
    ];

    # Install Helmfile and Helm with plugins
    environment.systemPackages = with pkgs; [
      helmfile
      kubernetes-helm
    ] ++ optionals cfg.enableDiff [
      kubernetes-helm-wrapped
    ] ++ cfg.extraPlugins;

    # Set up Helm completion for shells
    programs.bash.completion.enable = true;
    programs.zsh.enable = true;
    
    # Environment variables for Helmfile
    environment.variables = {
      # Use kubectl from k3s if available, otherwise system kubectl
      KUBECTL_BINARY = "/run/current-system/sw/bin/kubectl";
      # Default Helm chart cache location
      HELM_CACHE_HOME = "/tmp/helm-cache";
      # Default Helm config directory
      HELM_CONFIG_HOME = "/etc/helm";
    };
    
    # Create helm config directory with proper permissions
    systemd.tmpfiles.rules = [
      "d /etc/helm 0755 root root -"
      "d /tmp/helm-cache 0755 root root -"
    ];
  };
}