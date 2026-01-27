# Layered System-level NixOS modules following recursion prevention guidelines
{ config, lib, pkgs, ... }:

{
  imports = [
    # Layer 1: Core modules (no dependencies)
    ./01-core/system/user.nix
    ./01-core/system/secrets.nix
    ./01-core/system/fonts.nix
    ./01-core/system/validation-enhanced.nix
    
    # Layer 2: Hardware modules (depends on core)
    ./02-hardware/system/laptop.nix
    ./02-hardware/system/desktop.nix
    ./02-hardware/system/server.nix
    
    # Layer 3: Services modules (depends on core + hardware)
    ./03-services/system/docker.nix
    ./03-services/system/k3s.nix
    ./03-services/system/mongodb-ce.nix
    ./03-services/system/open-iscsi.nix
    ./03-services/system/openvpn.nix
    ./03-services/system/redis.nix
    ./03-services/system/teamviewer.nix
    ./03-services/system/wireguard.nix
    ./03-services/system/prowlarr.nix
    ./03-services/system/sonarr.nix
    ./03-services/system/qbittorrent.nix
    
    # Layer 4: Applications (depends on services) - system-only tools
    # AI & Machine Learning
    ./04-applications/system/tools/ai-ml/llm/default.nix
    
    # Browsers
    ./04-applications/system/tools/browsers/brave.nix
    ./04-applications/system/tools/browsers/chromium.nix
    ./04-applications/system/tools/browsers/tor-browser/default.nix
    
    # Containers
    ./04-applications/system/tools/containers/kubernetes/argocd.nix
    ./04-applications/system/tools/containers/kubernetes/helmfile.nix
    
    # Data Management
    ./04-applications/system/tools/data/analysis/linuxquota.nix
    ./04-applications/system/tools/data/analysis/qdirstat.nix
    ./04-applications/system/tools/data/backup/restic.nix
    ./04-applications/system/tools/data/sync/syncthing.nix
    
    # Desktop Environment
    ./04-applications/system/tools/desktop/input/keyd.nix
    ./04-applications/system/tools/desktop/themes/gtk.nix
    ./04-applications/system/tools/desktop/monitoring.nix
    
    # Development Tools
    ./04-applications/system/tools/development/api-tools/postman.nix
    ./04-applications/system/tools/development/api-tools/stripe-cli.nix
    ./04-applications/system/tools/development/languages/golang.nix
    ./04-applications/system/tools/development/languages/python3.nix
    ./04-applications/system/tools/development/languages/npm.nix
    ./04-applications/system/tools/development/languages/bun.nix
    ./04-applications/system/tools/development/core-tools.nix
    ./04-applications/system/tools/development/languages/java.nix
    ./04-applications/system/tools/development/pandoc.nix
    ./04-applications/system/tools/development/just.nix
    ./04-applications/system/tools/development/android-studio.nix
    
    # Infrastructure
    ./04-applications/system/tools/infrastructure/cloud/aws-cli.nix
    ./04-applications/system/tools/infrastructure/cloud/google-cloud-sdk.nix
    ./04-applications/system/tools/infrastructure/cloud/terraform.nix
    ./04-applications/system/tools/infrastructure/monitoring/blocky.nix
    ./04-applications/system/tools/infrastructure/monitoring/grafana.nix
    ./04-applications/system/tools/infrastructure/networking/mosh.nix
    ./04-applications/system/tools/infrastructure/networking/sshfs.nix
    ./04-applications/system/tools/infrastructure/networking/dig.nix
    ./04-applications/system/tools/infrastructure/networking/knot-dns.nix
    
    # Multimedia
    ./04-applications/system/tools/multimedia/gaming/steam.nix
    ./04-applications/system/tools/multimedia/knowledge/kiwix.nix
    ./04-applications/system/tools/multimedia/recording/simplescreenrecorder.nix
    ./04-applications/system/tools/multimedia/recording/screenshot-tools.nix
    ./04-applications/system/tools/multimedia/recording/obs.nix
    ./04-applications/system/tools/multimedia/recording/asciinema.nix
    ./04-applications/system/tools/multimedia/applications.nix
    
    # Security
    ./04-applications/system/tools/security/crypto/git-crypt.nix
    ./04-applications/system/tools/security/crypto/keepassxc.nix
    ./04-applications/system/tools/security/crypto/openssl.nix
    ./04-applications/system/tools/security/scanners/gitleaks.nix
    ./04-applications/system/tools/security/scanners/grype.nix
    ./04-applications/system/tools/security/scanners/semgrep.nix
    ./04-applications/system/tools/security/scanners/syft.nix
    ./04-applications/system/tools/security/scanners/trivy.nix
    ./04-applications/system/tools/security/wireshark.nix
    ./04-applications/system/tools/security/mitmproxy.nix
    
    # Terminal Tools
    ./04-applications/system/tools/terminal/emulators/alacritty-stub.nix
    
    # Version Control
    ./04-applications/system/tools/version-control/git-hybrid.nix
    
    # Virtualization
    ./04-applications/system/tools/virtualization/qemu.nix
    ./04-applications/system/tools/virtualization/firecracker.nix
    
    # Communication
    ./04-applications/system/tools/communication/messaging.nix
    
    # File Management
    ./04-applications/system/tools/file-management/managers.nix
    ./04-applications/system/tools/file-management/filezilla.nix
    
    # System Utilities
    ./04-applications/system/tools/system/core-utilities.nix
    
    # Note: Hybrid modules (alacritty, zsh, vscode, tmux, etc.) are in home-layered.nix
    # Note: Services (docker, k3s, wireguard) are in Layer 3
    
    # Layer 5: Tool bundles (depends on applications)
    ./05-bundles/tool-bundles/desktop.nix
    ./05-bundles/tool-bundles/development.nix
    ./05-bundles/tool-bundles/security.nix
    ./05-bundles/tool-bundles/server.nix
    ./05-bundles/tool-bundles/workstation.nix
    ./05-bundles/tool-bundles/server-stack.nix
    ./05-bundles/tool-bundles/terminal.nix
    ./05-bundles/tool-bundles/ai-ml.nix
    ./05-bundles/tool-bundles/content-creation.nix
    ./05-bundles/tool-bundles/kubernetes.nix
    ./05-bundles/tool-bundles/webdev.nix
    ./05-bundles/tool-bundles/devops.nix
    ./05-bundles/tool-bundles/remote-work.nix
    ./05-bundles/tool-bundles/gaming.nix
    
    # Layer 6: Profiles (depends on bundles)
    ./06-profiles/profiles/developer-workstation.nix
    ./06-profiles/profiles/gaming-workstation.nix
    ./06-profiles/profiles/home-server.nix
    ./06-profiles/profiles/minimal-desktop.nix
    ./06-profiles/profiles/comprehensive-workstation.nix
    
    # Additional system modules
    ./security/default.nix
    ./scripts/default.nix
    ./timezone.nix
  ];
}