{ config, pkgs, lib, ... }:

{
  # Don't allow mutation of users outside of Nix configuration.
  users.mutableUsers = false;

  # Default shell for all users
  users.defaultUserShell = pkgs.zsh;

  users.users.user = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel"    # Enable sudo
      "networkmanager"
      "docker"
      "audio"
      "video"
      "input"
    ];
    # Password will be set via agenix
    hashedPassword = null;
    
    # Enable home-manager for this user
    home = "/home/user";
    createHome = true;
  };

  # Home Manager configuration
  home-manager.users.user = { pkgs, config, lib, ... }: {
    imports = [
      ../../home/profiles/default.nix
    ];

    # Basic home-manager configuration
    home = {
      # Home Manager needs a bit of information about you and the
      # paths it should manage.
      username = "user";
      homeDirectory = "/home/user";

      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      stateVersion = "23.11";

      # Let Home Manager install and manage itself.
      enableNixpkgsReleaseCheck = true;
    };

    # Enable home-manager
    programs.home-manager.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
  };
}
