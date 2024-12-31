# User Configuration Module
#
# This is the main entry point for the user configuration system.
# It imports and combines all the individual configuration modules.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userConfig;
  customTypes = import ./types.nix { inherit lib; };
in {
  imports = [
    ./desktop.nix    # Desktop environment configuration
    ./development.nix # Development tools configuration
    ./security.nix   # Security settings configuration
    ./system.nix     # Core system configuration
  ];

  options = {
    userConfig = mkOption {
      type = with lib.types; nullOr (submodule {
        options = {
          # Identity
          identity = mkOption {
            type = customTypes.identityType;
            description = "User identity information";
          };

          # Authentication
          auth = mkOption {
            type = customTypes.authType;
            description = "User authentication settings";
          };

          # Keyboard
          keyboard = mkOption {
            type = customTypes.keyboardType;
            description = "Keyboard configuration";
          };

          # Shell
          shell = mkOption {
            type = customTypes.shellType;
            description = "Shell configuration";
          };

          # Desktop Environment
          desktop = mkOption {
            type = customTypes.desktopType;
            description = "Desktop environment configuration";
          };

          # Development
          development = mkOption {
            type = customTypes.developmentType;
            description = "Development environment configuration";
          };

          # Security
          security = mkOption {
            type = customTypes.securityType;
            description = "Security configuration";
          };

          # System
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

          backup = mkOption {
            type = types.submodule {
              options = {
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
            default = { enable = false; locations = []; };
            description = "Backup configuration";
          };
        };
      });
      default = null;
      description = ''
        User configuration settings. Set to null to disable user configuration.
        See the template at templates/user.nix for a complete example.
      '';
      example = literalExpression ''
        {
          identity = {
            username = "alice";
            fullName = "Alice Smith";
            email = "alice@example.com";
          };
          auth = {
            hashedPassword = null;  # Set via agenix
            sshKeys = [ "ssh-ed25519 AAAAC3..." ];
          };
          keyboard = {
            layout = "us";
            variant = "dvorak";
            options = [ "caps:escape" ];
          };
        }
      '';
    };
  };

  config = mkIf (config.userConfig != null) {
    warnings = optional
      (config.userConfig.auth.hashedPassword == null)
      "No password set for user ${config.userConfig.identity.username}. Set auth.hashedPassword or use agenix.";

    assertions = [
      {
        assertion = config.userConfig.identity.username != "";
        message = "Username must not be empty";
      }
      {
        assertion = config.userConfig.identity.fullName != "";
        message = "Full name must not be empty";
      }
      {
        assertion = config.userConfig.identity.email != "";
        message = "Email must not be empty";
      }
    ];
  };
}
