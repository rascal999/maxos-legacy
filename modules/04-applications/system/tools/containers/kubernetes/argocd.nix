{ config, lib, pkgs, ... }:

# This module installs the ArgoCD CLI tool.
# ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes.
#
# Features:
# - Installs argocd CLI tool for managing ArgoCD applications
# - Provides command completion for bash and zsh

with lib;

let
  cfg = config.maxos.tools.argocd;
in {
  options.maxos.tools.argocd = {
    enable = mkEnableOption "ArgoCD CLI tool";
  };

  config = mkIf cfg.enable {
    # Install ArgoCD CLI
    environment.systemPackages = with pkgs; [
      argocd
    ];

    # Enable bash completion for argocd
    programs.bash.completion.enable = true;
    
    # Enable zsh completion for argocd
    programs.zsh.enable = true;
  };
}