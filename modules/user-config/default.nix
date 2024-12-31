# User Configuration Module
#
# This is the main entry point for the user configuration system.
# It imports and combines all the individual configuration modules.

{ config, lib, pkgs, ... }:

with lib;

let
  types = import ./types.nix { inherit lib; };
in {
  imports = [
    ./desktop.nix    # Desktop environment configuration
    ./development.nix # Development tools configuration
    ./security.nix   # Security settings configuration
    ./system.nix     # Core system configuration
  ];

  options = {
    userConfig = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          # Identity
          identity = mkOption {
            type = types.identityType;
            description = "User identity information";
          };

          # Authentication
          auth = mkOption {
            type = types.authType;
            description = "User authentication settings";
          };

          # Keyboard
          keyboard = mkOption {
            type = types.keyboardType;
            description = "Keyboard configuration";
          };

          # Shell
          shell = mkOption {
            type = types.shellType;
            description = "Shell configuration";
          };

          # Desktop Environment
          desktop = mkOption {
            type = types.desktopType;
            description = "Desktop environment configuration";
          };

          # Development
          development = mkOption {
            type = types.developmentType;
            description = "Development environment configuration";
          };

          # Security
          security = mkOption {
            type = types.securityType;
            description = "Security configuration";
          };

          # System
          extraGroups = mkOption {
            type = types.systemType.options.extraGroups.type;
            default = types.systemType.options.extraGroups.default;
            description = types.systemType.options.extraGroups.description;
          };

          extraPackages = mkOption {
            type = types.systemType.options.extraPackages.type;
            default = types.systemType.options.extraPackages.default;
            description = types.systemType.options.extraPackages.description;
          };

          services = mkOption {
            type = types.systemType.options.services.type;
            default = types.systemType.options.services.default;
            description = types.systemType.options.services.description;
          };

          mounts = mkOption {
            type = types.systemType.options.mounts.type;
            default = types.systemType.options.mounts.default;
            description = types.systemType.options.mounts.description;
          };

          backup = mkOption {
            type = types.systemType.options.backup.type;
            default = types.systemType.options.backup.default;
            description = types.systemType.options.backup.description;
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
