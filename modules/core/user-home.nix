# Home-manager user configuration module
{ config, lib, pkgs, osConfig ? {}, ... }:

with lib;

let
  # Get system user config when available
  systemUserConfig = osConfig.maxos.user or {};
in {
  # Re-expose system user config options for home-manager modules to access
  options.maxos.user = {
    name = mkOption {
      type = types.str;
      default = systemUserConfig.name or "user";
      description = "Primary user name (read from system config)";
    };
    
    homeDirectory = mkOption {
      type = types.str;
      default = systemUserConfig.homeDirectory or "/home/user";
      description = "User home directory (read from system config)";
    };
    
    workspaceDirectory = mkOption {
      type = types.str;
      default = systemUserConfig.workspaceDirectory or "/home/user/workspace";
      description = "Workspace directory (read from system config)";
    };
    
    monorepoDirectory = mkOption {
      type = types.str;
      default = systemUserConfig.monorepoDirectory or "/home/user/monorepo/tools/goose/workspace";
      description = "Default workspace directory (read from system config)";
    };
    
    email = mkOption {
      type = types.str;
      default = systemUserConfig.email or "user@example.com";
      description = "User's email address (read from system config)";
    };
    
    fullName = mkOption {
      type = types.str;
      default = systemUserConfig.fullName or "MaxOS User";
      description = "User's full name (read from system config)";
    };
  };

  config = {
    # No system configuration - just expose the unified config for home-manager modules
  };
}