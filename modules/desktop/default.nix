{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
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
