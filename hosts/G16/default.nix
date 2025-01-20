{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ./boot.nix
    ./nvidia.nix
    ./rog.nix
    ./audio.nix
    ../../modules/security/default.nix
    ../../modules/desktop/default.nix
    ../../modules/hardware/network.nix
  ];

  # Disable system-wide Firefox
  programs.firefox.enable = false;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable security module with default settings
  security.enable = true;

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

    # Touchpad configuration
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = false;
        disableWhileTyping = true;
        scrollMethod = "twofinger";
        tapping = true;
        tappingDragLock = false;
      };
    };

    # Server flags
    serverFlagsSection = ''
      Option "AllowEmptyInput" "on"
      Option "AutoAddDevices" "on"
      Option "AutoEnableDevices" "on"
    '';

    # Display manager configuration
    displayManager = {
      defaultSession = "none+i3";
      # Add display setup script for NVIDIA
      setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --auto
        ${pkgs.xorg.xset}/bin/xset s off -dpms
      '';
      lightdm = {
        enable = true;
        background = "#000000";
        greeters.gtk = {
          enable = true;
          theme.name = "Adwaita-dark";
        };
      };
    };
  };

  # Add required packages
  environment.systemPackages = with pkgs; [
    # NVIDIA utilities
    nvidia-vaapi-driver
    glxinfo
    vulkan-tools
  ];

  # Disable Redshift service to avoid conflicts
  services.redshift.enable = false;

  # Configure home-manager
  home-manager = {
    backupFileExtension = "backup";
    users.user = { pkgs, ... }: {
      imports = [
        ./home.nix
        ../../modules/tools/i3/desktop.nix
        ../../modules/tools/alacritty.nix
        ../../modules/tools/zsh.nix
      ];
    };
  };

  # Set system state version
  system.stateVersion = "24.11";
}
