{ config, lib, pkgs, osConfig ? {}, ... }:

with lib;

let
  cfg = config.maxos.user;
in {
  options.maxos.user = {
    name = mkOption {
      type = types.str;
      default = "user";
      description = "Primary user name";
    };
    
    homeDirectory = mkOption {
      type = types.str;
      default = "/home/user";
      description = "User's home directory path";
    };
    
    gitDirectory = mkOption {
      type = types.str;
      default = "/home/user/git";
      description = "Directory containing git repositories";
    };
    
    monorepoDirectory = mkOption {
      type = types.str;
      default = "/home/user/git/github/monorepo";
      description = "Path to the main monorepo";
    };
    
    secretsDirectory = mkOption {
      type = types.str;
      default = "/home/user/git/github/monorepo/secrets";
      description = "Directory containing secret files";
    };
    
    workspaceDirectory = mkOption {
      type = types.str;
      default = "/home/user/monorepo/tools/goose/workspace";
      description = "Default workspace directory";
    };
    
    # Additional unified config options
    email = mkOption {
      type = types.str;
      default = "user@example.com";
      description = "User's email address";
    };
    
    fullName = mkOption {
      type = types.str;
      default = "MaxOS User";
      description = "User's full name";
    };
  };

  config = {
    # System user configuration - always applied in system context
    users.users.${cfg.name} = {
      isNormalUser = true;
      home = cfg.homeDirectory;
      extraGroups = [ "wheel" "networkmanager" "docker" ];
    };
  };
}