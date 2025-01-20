{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # Add user to video group for screen color temperature control
  users.users.user.extraGroups = [ "video" ];

  # Configure sct for constant warm color temperature
  systemd.user.services.sct = {
    description = "Set color temperature using sct";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.sct}/bin/sct 1900";
      ExecStop = "${pkgs.sct}/bin/sct";
      Environment = "DISPLAY=:0";
      RuntimeDirectory = "sct";
      RuntimeDirectoryMode = "0755";
    };
    path = [ pkgs.xorg.xauth ];
  };

  # X server configuration
  services.xserver = {
    enable = true;
    displayManager = {
      autoLogin = {
        enable = true;
        user = "user";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    sct
    xorg.xrandr
  ];
}
