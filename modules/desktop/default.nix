{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # Configure gammastep for constant warm color temperature
  home-manager.users.user.services.gammastep = {
    enable = true;
    provider = "manual";
    temperature = {
      day = 1900;
      night = 1900;
    };
    dawnTime = "00:00";
    duskTime = "00:00";
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
