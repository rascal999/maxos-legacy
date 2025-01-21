{ config, lib, ... }:

with lib;

let
  cfg = config.security;
in {
  config = mkIf cfg.enable {
    # Configure sudo to not require password
    security.sudo.extraRules = [
      {
        users = [ "user" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    security.pam.loginLimits = [
      {
        domain = "*";
        item = "maxlogins";
        type = "-";
        value = 10;
      }
    ];

    # Enable fail2ban for brute force protection
    services.fail2ban = {
      enable = true;
      jails = {
        ssh-iptables = ''
          enabled = true
          filter = sshd
          action = iptables[name=SSH, port=ssh, protocol=tcp]
          logpath = /var/log/auth.log
          maxretry = 3
          findtime = 600
          bantime = 600
        '';
      };
    };
  };
}
