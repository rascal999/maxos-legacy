{ config, lib, pkgs, ... }:

{
  # Common desktop configuration
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-27.3.11"
    ];
  };

  # Configure sct for constant warm color temperature
  systemd.user.services.sct = {
    description = "Set color temperature using sct";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.sct}/bin/sct 1900";
      ExecStop = "${pkgs.sct}/bin/sct";
    };
  };

  environment.systemPackages = with pkgs; [
    sct
  ];


  # X server configuration
  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "user";
      };
    };
  };
}
