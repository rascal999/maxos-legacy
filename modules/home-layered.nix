# Layered Home-manager modules following recursion prevention guidelines
{ config, lib, pkgs, ... }:

{
  imports = [
    # Layer 1: Core home-manager modules
    # ./01-core/home/user-settings.nix
    
    # Layer 2: Hardware-specific home configs
    # ./02-hardware/home/display.nix
    
    # Layer 3: Service-related home configs
    # ./03-services/home/user-services.nix
    
    # Layer 4: Applications (home-manager only)
    ./04-applications/home/vscode.nix
    ./04-applications/home/terminal/shells/zsh.nix
    ./04-applications/home/terminal/emulators/alacritty.nix
    ./04-applications/home/terminal/multiplexers/tmux.nix
    ./04-applications/home/development/environment/direnv.nix
    ./04-applications/home/browsers/firefox/default.nix
    ./04-applications/home/multimedia/knowledge/logseq.nix
    ./04-applications/home/infrastructure/networking/remmina.nix
    ./04-applications/home/desktop/window-managers/i3/base.nix
    # Add more pure home-manager modules here:
    # ./04-applications/home/git.nix
    
    # Layer 5: Home-manager bundles
    # ./05-bundles/home/development.nix
    
    # Layer 6: Home-manager profiles
    # ./06-profiles/home/developer.nix
  ];
}