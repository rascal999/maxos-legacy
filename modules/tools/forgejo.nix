{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.forgejo;
in
{
  options.modules.tools.forgejo = {
    enable = mkEnableOption "Forgejo Git service";

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port for Forgejo web interface";
    };

    domain = mkOption {
      type = types.str;
      default = "localhost";
      description = "Domain name for Forgejo instance";
    };

    rootUrl = mkOption {
      type = types.str;
      default = "http://localhost:3000/";
      description = "Root URL for Forgejo instance";
    };

    ssh = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SSH access for Git operations";
      };

      port = mkOption {
        type = types.port;
        default = 2222;
        description = "Port for Forgejo SSH server";
      };
    };

    database = {
      type = mkOption {
        type = types.enum [ "sqlite3" "mysql" "postgres" ];
        default = "sqlite3";
        description = "Database type to use";
      };

      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Database host";
      };

      port = mkOption {
        type = types.port;
        default = 5432;
        description = "Database port";
      };

      name = mkOption {
        type = types.str;
        default = "forgejo";
        description = "Database name";
      };

      user = mkOption {
        type = types.str;
        default = "forgejo";
        description = "Database user";
      };

      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing database password";
      };
    };

    actions = {
      enable = mkEnableOption "Forgejo Actions (CI/CD)";
    };

    lfs = {
      enable = mkEnableOption "Git LFS support";
    };

    mailerSettings = {
      enable = mkEnableOption "Email notifications";
      
      host = mkOption {
        type = types.str;
        default = "";
        description = "SMTP host";
      };

      port = mkOption {
        type = types.port;
        default = 587;
        description = "SMTP port";
      };

      user = mkOption {
        type = types.str;
        default = "";
        description = "SMTP user";
      };

      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing SMTP password";
      };

      from = mkOption {
        type = types.str;
        default = "";
        description = "From email address";
      };
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = {};
      description = "Extra configuration options for Forgejo";
    };
  };

  config = mkIf cfg.enable {
    services.forgejo = {
      enable = true;
      database.type = cfg.database.type;
      lfs.enable = cfg.lfs.enable;
      
      settings = {
        server = {
          DOMAIN = cfg.domain;
          HTTP_PORT = cfg.port;
          ROOT_URL = cfg.rootUrl;
          DISABLE_SSH = !cfg.ssh.enable;
          START_SSH_SERVER = cfg.ssh.enable;
          SSH_PORT = cfg.ssh.port;
        };

        service = {
          DISABLE_REGISTRATION = false;
        };

        actions = mkIf cfg.actions.enable {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };

        mailer = mkIf cfg.mailerSettings.enable {
          ENABLED = true;
          SMTP_ADDR = cfg.mailerSettings.host;
          SMTP_PORT = cfg.mailerSettings.port;
          USER = cfg.mailerSettings.user;
          FROM = cfg.mailerSettings.from;
        };
      } // cfg.extraConfig;

      mailerPasswordFile = mkIf (cfg.mailerSettings.enable && cfg.mailerSettings.passwordFile != null) cfg.mailerSettings.passwordFile;
    };

    # Open firewall for Forgejo
    networking.firewall.allowedTCPPorts = [ cfg.port ] ++ optionals cfg.ssh.enable [ cfg.ssh.port ];

    # Ensure forgejo user exists
    users.users.forgejo = {
      isSystemUser = true;
      group = "forgejo";
      home = "/var/lib/forgejo";
      createHome = true;
      shell = pkgs.bash;
    };

    users.groups.forgejo = {};

    # Create necessary directories
    systemd.tmpfiles.rules = [
      "d /var/lib/forgejo 0750 forgejo forgejo -"
      "d /var/lib/forgejo/log 0750 forgejo forgejo -"
      "d /var/lib/forgejo/data 0750 forgejo forgejo -"
      "d /var/lib/forgejo/custom 0750 forgejo forgejo -"
    ];

    # NixOS Forgejo service handles secret generation automatically
  };
}