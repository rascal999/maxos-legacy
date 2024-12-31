# User Configuration Types
#
# This file defines all the types used in the user configuration system.

{ lib, ... }:

with lib;

{
  # Identity types
  identityType = types.submodule {
    options = {
      username = mkOption {
        type = types.str;
        description = "Unix username";
        example = "alice";
      };
      fullName = mkOption {
        type = types.str;
        description = "User's full name";
        example = "Alice Smith";
      };
      email = mkOption {
        type = types.str;
        description = "User's email address";
        example = "alice@example.com";
      };
    };
  };

  # Authentication types
  authType = types.submodule {
    options = {
      hashedPassword = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Hashed password for the user account";
      };
      sshKeys = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of SSH public keys for remote access";
      };
    };
  };

  # Keyboard types
  keyboardType = types.submodule {
    options = {
      layout = mkOption {
        type = types.str;
        default = "us";
        description = "Keyboard layout";
      };
      variant = mkOption {
        type = types.str;
        default = "";
        description = "Keyboard variant";
      };
      options = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Keyboard options";
      };
    };
  };

  # Shell types
  shellType = types.submodule {
    options = {
      default = mkOption {
        type = types.enum [ "zsh" "bash" ];
        default = "zsh";
        description = "Default shell";
      };
      enableCompletion = mkOption {
        type = types.bool;
        default = true;
        description = "Enable shell completion";
      };
      enableSyntaxHighlighting = mkOption {
        type = types.bool;
        default = true;
        description = "Enable shell syntax highlighting";
      };
      aliases = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Shell aliases";
      };
    };
  };

  # Desktop types
  desktopType = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable desktop environment";
      };
      environment = mkOption {
        type = types.enum [ "i3" "gnome" "kde" "xfce" ];
        default = "i3";
        description = "Desktop environment";
      };
      theme = {
        name = mkOption {
          type = types.enum [ "dark" "light" ];
          default = "dark";
          description = "Theme variant";
        };
        gtk = {
          theme = mkOption {
            type = types.str;
            default = "Adwaita-dark";
            description = "GTK theme";
          };
          iconTheme = mkOption {
            type = types.str;
            default = "Papirus-Dark";
            description = "Icon theme";
          };
        };
        cursor = {
          theme = mkOption {
            type = types.str;
            default = "Adwaita";
            description = "Cursor theme";
          };
          size = mkOption {
            type = types.int;
            default = 24;
            description = "Cursor size";
          };
        };
      };
      fonts = {
        monospace = mkOption {
          type = types.str;
          default = "JetBrains Mono";
          description = "Monospace font";
        };
        interface = mkOption {
          type = types.str;
          default = "Inter";
          description = "Interface font";
        };
        size = mkOption {
          type = types.int;
          default = 11;
          description = "Font size";
        };
        scaling = mkOption {
          type = types.float;
          default = 1.0;
          description = "Font scaling factor";
        };
      };
      terminal = {
        program = mkOption {
          type = types.str;
          default = "alacritty";
          description = "Terminal emulator";
        };
        opacity = mkOption {
          type = types.float;
          default = 0.95;
          description = "Terminal opacity";
        };
        fontSize = mkOption {
          type = types.int;
          default = 12;
          description = "Terminal font size";
        };
      };
    };
  };

  # Development types
  developmentType = types.submodule {
    options = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable development tools";
      };
      git = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable Git configuration";
        };
        userName = mkOption {
          type = types.str;
          description = "Git user name";
        };
        userEmail = mkOption {
          type = types.str;
          description = "Git user email";
        };
        signingKey = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "GPG key for signing commits";
        };
        editor = mkOption {
          type = types.str;
          default = "nvim";
          description = "Git editor";
        };
      };
      containers = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable container support";
        };
        virtualisation = mkOption {
          type = types.bool;
          default = false;
          description = "Enable virtualisation support";
        };
      };
      languages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Development language tools";
      };
      editors = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Code editors";
      };
    };
  };

  # Security types
  securityType = types.submodule {
    options = {
      gpg = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable GPG support";
        };
      };
      yubikey = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable YubiKey support";
        };
        pam = mkOption {
          type = types.bool;
          default = true;
          description = "Enable YubiKey PAM authentication";
        };
      };
      firewall = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable firewall";
        };
        allowedTCPPorts = mkOption {
          type = types.listOf types.port;
          default = [];
          description = "Allowed TCP ports";
        };
        allowedUDPPorts = mkOption {
          type = types.listOf types.port;
          default = [];
          description = "Allowed UDP ports";
        };
      };
    };
  };

  # System types
  systemType = types.submodule {
    options = {
      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional groups for the user";
      };
      extraPackages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Additional packages to install";
      };
      services = mkOption {
        type = types.attrs;
        default = {};
        description = "Service configurations";
      };
      mounts = mkOption {
        type = types.listOf (types.submodule {
          options = {
            source = mkOption {
              type = types.str;
              description = "Mount source";
            };
            target = mkOption {
              type = types.str;
              description = "Mount target";
            };
            type = mkOption {
              type = types.str;
              description = "Filesystem type";
            };
            options = mkOption {
              type = types.listOf types.str;
              default = [ "auto" "nofail" ];
              description = "Mount options";
            };
          };
        });
        default = [];
        description = "Network mounts";
      };
      backup = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable backup configuration";
        };
        locations = mkOption {
          type = types.listOf (types.submodule {
            options = {
              path = mkOption {
                type = types.str;
                description = "Path to backup";
              };
              destination = mkOption {
                type = types.str;
                description = "Backup destination";
              };
              frequency = mkOption {
                type = types.str;
                default = "daily";
                description = "Backup frequency";
              };
              retention = mkOption {
                type = types.str;
                default = "30d";
                description = "Backup retention period";
              };
            };
          });
          default = [];
          description = "Backup locations";
        };
      };
    };
  };
}
