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
    redshift
  ];

  # Common startup applications
  systemd.user.services.redshift = {
    description = "Redshift color temperature adjuster";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.redshift}/bin/redshift -O 1900";
      Type = "oneshot";
      RemainAfterExit = "yes";
    };
  };

  # X server configuration
  services.xserver = {
    displayManager = {
      sessionCommands = ''
        # Enable Firefox touchpad gestures
        export MOZ_USE_XINPUT2=1
      '';
    };
  };
}
