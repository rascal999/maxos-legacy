{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # HiDPI settings
  services.xserver = {
    dpi = 192; # Adjust based on screen
    displayManager = {
      sessionCommands = ''
        # Set GDK scaling
        export GDK_SCALE=2
        export GDK_DPI_SCALE=0.5
        # Set Qt scaling
        export QT_AUTO_SCREEN_SCALE_FACTOR=1
        # Set Firefox scaling
        export MOZ_USE_XINPUT2=1
      '';
    };
  };
}
