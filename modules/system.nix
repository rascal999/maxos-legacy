# System-level NixOS modules only
{ config, lib, pkgs, ... }:

{
  imports = [
    # Core modules
    ./core/user.nix
    ./core/secrets.nix
    
    # Tool bundles
    ./tool-bundles/desktop.nix
    ./tool-bundles/development.nix
    ./tool-bundles/security.nix
    ./tool-bundles/server.nix
    
    # System-level tool modules only
    ./tools/blocky.nix
    ./tools/chromium.nix
    ./tools/docker.nix
    ./tools/docker-network.nix
    ./tools/faas-cli.nix
    ./tools/forgejo.nix
    ./tools/forgejo-cli.nix
    ./tools/forgejo-runner.nix
    ./tools/gitleaks.nix
    ./tools/golang.nix
    ./tools/grafana.nix
    ./tools/grype.nix
    ./tools/k3s.nix
    ./tools/keepassxc.nix
    ./tools/keyd.nix
    ./tools/kind.nix
    ./tools/kiwix.nix
    ./tools/linuxquota.nix
    ./tools/mongodb.nix
    ./tools/npm.nix
    ./tools/openssl.nix
    ./tools/postman.nix
    ./tools/pulseaudio-docker.nix
    ./tools/qdirstat.nix
    # ./tools/qemu.nix           # Has invalid options
    ./tools/restic.nix
    ./tools/rocketchat.nix
    ./tools/semgrep.nix
    ./tools/simplescreenrecorder.nix
    ./tools/skaffold.nix
    ./tools/syncthing.nix
    ./tools/syft.nix
    ./tools/traefik.nix
    ./tools/trivy.nix
    # ./tools/vscode-unmanaged.nix  # Home-manager module
    ./tools/whatsapp-mcp.nix
    ./tools/wireguard.nix
    ./tools/x11-docker.nix
    ./tools/gpsbabel.nix
    
    # LLM tools
    ./tools/llm/default.nix
    
    # Other subdirectory modules
    # ./tools/tor-browser/default.nix  # May have conflicts
  ];
}