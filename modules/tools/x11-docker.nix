{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.x11-docker;
in {
  options.modules.tools.x11-docker = {
    enable = mkEnableOption "X11 Docker integration";
  };

  config = mkIf cfg.enable {
    # Configure X11 to allow connections from Docker containers
    services.xserver.extraConfig = ''
      Section "ServerFlags"
        Option "AllowMouseOpenFail" "true"
        Option "AllowTouchOpenFail" "true"
      EndSection
    '';
    
    # Add X11 utilities
    environment.systemPackages = with pkgs; [
      xorg.xhost
      xorg.xauth
      xdotool
      xclip
      python3Packages.pyautogui
    ];
    
    # Create a script to allow X11 connections from Docker
    environment.etc."x11-docker-init.sh" = {
      text = ''
        #!/bin/sh
        xhost +local:docker
      '';
      mode = "0755";
    };
    
    # Add a systemd service to run the script at startup
    systemd.user.services.x11-docker-init = {
      description = "Initialize X11 for Docker";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash /etc/x11-docker-init.sh";
        RemainAfterExit = true;
      };
    };
  };
}