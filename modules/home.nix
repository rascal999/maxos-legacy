# Home-manager modules with dynamic discovery
{ config, lib, pkgs, ... }:

let
  moduleDiscovery = import ../lib/module-discovery.nix { inherit lib; };
  
  # Define home-manager modules (those that use programs.* or home.*)
  homeManagerModules = [
    "alacritty"
    "claude-code"
    "direnv"
    "logseq"
    "micromamba"
    "tmux"
    "vscode"
    "zsh"
  ];
  
  # Discover all available tool modules
  allToolModules = moduleDiscovery.discoverNixFiles ./tools;
  
  # Filter to only include home-manager modules
  homeToolImports = builtins.filter (path: path != null) (
    map (name: 
      if builtins.hasAttr name allToolModules 
      then allToolModules.${name}
      else null
    ) homeManagerModules
  );
  
  # Additional hybrid modules that work in both contexts (disabled due to recursion issues)
  hybridModules = [
    # ./tools/git-hybrid.nix
    # ./tools/docker-hybrid.nix
  ];

in {
  imports = homeToolImports ++ hybridModules;
}