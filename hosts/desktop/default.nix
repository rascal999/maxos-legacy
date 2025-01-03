{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ../../modules/security/default.nix
  ];

  # Enable zsh
  programs.zsh.enable = true;

  # Enable security module with default settings
  security.enable = true;

  # Enable X11 windowing system
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    windowManager.i3.enable = true;
    
    # Keyboard layout
    layout = "us";
    xkbVariant = "dvorak";
    xkbOptions = "terminate:ctrl_alt_bksp";
  };

  # Configure home-manager
  home-manager.users.user = { pkgs, ... }: {
    imports = [
      ./home.nix
      ../../modules/tools/i3/desktop.nix
      ../../modules/tools/alacritty.nix
      ../../modules/tools/zsh.nix
    ];
  };

  # Set system state version
  system.stateVersion = "23.11";
}
