{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # Common desktop packages
  environment.systemPackages = with pkgs; [
    gammastep
  ];

  # Enable and configure gammastep (Wayland-compatible redshift)
  services.gammastep = {
    enable = true;
    temperature = {
      day = 5500;
      night = 1900;
    };
    provider = "manual"; # Avoid geoclue dependency
    latitude = 51.5;     # London coordinates as default
    longitude = -0.1;    # Adjust these based on location
  };

  # X server configuration
  services.xserver = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "user";
      };
      sessionCommands = ''
        # Enable Firefox touchpad gestures
        export MOZ_USE_XINPUT2=1
      '';
    };
  };
}
