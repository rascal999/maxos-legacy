# System-level NixOS modules with dynamic discovery
{ config, lib, pkgs, ... }:

let
  moduleDiscovery = import ../lib/module-discovery.nix { inherit lib; };
  
  # Define system-level modules (those that don't use home-manager)
  systemLevelModules = [
    "blocky"
    "chromium" 
    "docker"
    "docker-network"
    "faas-cli"
    "forgejo"
    "forgejo-cli"
    "forgejo-runner"
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
    "mongodb"
    "npm"
    "openssl"
    "postman"
    "pulseaudio-docker"
    "qdirstat"
    "restic"
    "rocketchat"
    "semgrep"
    "simplescreenrecorder"
    "skaffold"
    "syncthing"
    "syft"
    "traefik"
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
  ] 
  # Dynamically discovered system-level tool modules
  ++ systemToolImports
  # Additional static modules
  ++ staticModules;
}