{ config, lib, ... }:

with lib;

let
  cfg = config.security;
in {
  options.security = {
    authorizedKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of SSH public keys that are allowed to log in";
    };
  };

  config = mkIf (cfg.enable && cfg.sshHardening) {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;   # Allow password authentication
        PubkeyAuthentication = true;     # Also allow key-based authentication
        PermitRootLogin = "no";
        X11Forwarding = false;
        MaxAuthTries = 3;
      };
    };

    users.users.user.openssh.authorizedKeys.keys = cfg.authorizedKeys;
  };
}
