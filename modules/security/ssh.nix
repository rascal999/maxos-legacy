{ config, lib, ... }:

with lib;

let
  cfg = config.security;
in {
  config = mkIf (cfg.enable && cfg.sshHardening) {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
        MaxAuthTries = 3;
      };
    };
  };
}
