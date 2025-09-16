# System-level NixOS modules with dynamic discovery
{ config, lib, pkgs, ... }:

let
  moduleDiscovery = import ../lib/module-discovery.nix { inherit lib; };
  
  # Define system-level modules (those that don't use home-manager)
  systemLevelModules = [
    "argocd"
    "blocky"
    "chromium" 
    "docker"
    "docker-network"
    "gitleaks"
    "golang"
    "grafana"
    "grype"
    "k3s"
    "keepassxc"
    "keyd"
    "kind"
    "kiwix"
    "linuxquota"
    "npm"
    "openssl"
    "postman"
    "pulseaudio-docker"
    "qdirstat"
    "restic"
    "semgrep"
    "simplescreenrecorder"
    "steam"
    "syft"
    "trivy"
    "whatsapp-mcp"
    "wireguard"
    "x11-docker"
    "gpsbabel"
  ];
  
  # Discover all available tool modules
  allToolModules = moduleDiscovery.discoverNixFiles ./tools;
  
  # Filter to only include system-level modules
  systemToolImports = builtins.filter (path: path != null) (
    map (name: 
      if builtins.hasAttr name allToolModules 
      then allToolModules.${name}
      else null
    ) systemLevelModules
  );
  
  # Additional static modules
  staticModules = [
    # LLM tools subdirectory
    ./tools/llm/default.nix
    # Hybrid modules (disabled due to context detection issues - needs more work)
    # ./tools/git-hybrid.nix
    # ./tools/docker-hybrid.nix
  ];
  
in {
  imports = [
    # Core modules
    ./core/user.nix
    ./core/secrets.nix
    ./core/validation.nix
    ./core/profiles.nix
    ./core/dependencies.nix
    
    # Tool bundles
    ./tool-bundles/desktop.nix
    ./tool-bundles/development.nix
    ./tool-bundles/security.nix
    ./tool-bundles/server.nix
    
    # New tool bundles
    ./tool-bundles/workstation.nix
    ./tool-bundles/server-stack.nix
    ./tool-bundles/terminal.nix
    ./tool-bundles/ai-ml.nix
    ./tool-bundles/content-creation.nix
    ./tool-bundles/kubernetes.nix
    ./tool-bundles/webdev.nix
    ./tool-bundles/devops.nix
    ./tool-bundles/remote-work.nix
    ./tool-bundles/gaming.nix
  ] 
  # Dynamically discovered system-level tool modules
  ++ systemToolImports
  # Additional static modules
  ++ staticModules;
}