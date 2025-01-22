{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "user";
    dataDir = "/home/user";
    configDir = "/home/user/.config/syncthing";
    overrideDevices = true;     # Overwrite any devices added or deleted through the WebUI
    overrideFolders = true;     # Overwrite any folders added or deleted through the WebUI
    settings = {
      folders = {
        "share" = {
          path = "/home/user/share";
          devices = [ ];  # Add device IDs here when pairing
        };
      };
      gui = {
        address = "127.0.0.1:8384";
      };
    };
  };

  # Open required ports in firewall
  networking.firewall = {
    allowedTCPPorts = [ 8384 22000 ];  # 8384 for WebUI, 22000 for sync protocol
    allowedUDPPorts = [ 22000 21027 ];  # 22000 for sync protocol, 21027 for discovery broadcasts
  };
}
