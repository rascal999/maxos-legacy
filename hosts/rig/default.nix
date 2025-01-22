{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ./boot.nix
    ./nvidia.nix
    ./audio.nix
    ./monitors.nix
    ../../modules/security/default.nix
    ../../modules/desktop/default.nix
    ../../modules/hardware/network.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/tools/syncthing.nix
  ];

  # Disable system-wide Firefox
  programs.firefox.enable = false;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable security module with default settings
  security.enable = true;

  # Set hostname
  networking.hostName = "rig";

  # X11 configuration
  services.xserver = {
    enable = true;

    # Window manager configuration
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
    };

    # Keyboard layout
    xkb = {
      layout = "us";
      variant = "dvorak";
      options = "terminate:ctrl_alt_bksp";
    };

    # Display manager configuration
    displayManager.lightdm = {
      enable = true;
      background = "#000000";
      greeters.gtk = {
        enable = true;
        theme.name = "Adwaita-dark";
      };
    };
  };

  # Display manager session configuration
  services.displayManager.defaultSession = "none+i3";

  # Add required packages
  environment.systemPackages = with pkgs; [
    # Graphics utilities
    glxinfo
    xorg.xrandr
    # Qt theming
    libsForQt5.qt5ct
    adwaita-qt
  ];

  # Disable Redshift service to avoid conflicts
  services.redshift.enable = false;

  # Enable home-manager with backup support
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.user = { pkgs, ... }: {
      imports = [
        ./home.nix
        ../../modules/tools/i3/desktop.nix
        ../../modules/tools/alacritty.nix
        ../../modules/tools/zsh.nix
      ];

      # GTK configuration
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.adwaita-icon-theme;
        };
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };

      # Qt configuration
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style = {
          name = "adwaita-dark";
          package = pkgs.adwaita-qt;
        };
      };

      # Environment variables
      home.sessionVariables = {
        GTK_THEME = "Adwaita:dark";
        QT_QPA_PLATFORMTHEME = "qt5ct";
        HOST = config.networking.hostName;
      };
    };
  };

  # Set system state version
  system.stateVersion = "24.11";
}
