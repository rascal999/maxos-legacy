{ config, lib, pkgs, ... }:

{
  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = [ "nix-command" "flakes" ];
      
      # Optimize storage
      auto-optimise-store = true;
      
      # Trust users in this group to specify additional substituters
      trusted-users = [ "root" "@wheel" ];
      
      # Binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Enable nixops state linking
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    # Registry
    registry.nixpkgs.to = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };
  };

  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # System-wide nixpkgs configuration
  nixpkgs.config = {
    allowBroken = false;
    allowUnsupportedSystem = false;
  };
}
