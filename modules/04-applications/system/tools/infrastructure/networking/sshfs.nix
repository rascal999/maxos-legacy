{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.sshfs;
in {
  options.maxos.tools.sshfs = {
    enable = mkEnableOption "SSHFS (SSH Filesystem) support";
    
    allowOtherUsers = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow other users to access SSHFS mounts";
    };
    
    enableFuseGroup = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to create a fuse group for SSHFS access";
    };
  };

  config = mkIf cfg.enable {
    # Install SSHFS package
    environment.systemPackages = with pkgs; [
      sshfs
    ];

    # Enable FUSE support
    programs.fuse.userAllowOther = cfg.allowOtherUsers;

    # Create fuse group if enabled
    users.groups = mkIf cfg.enableFuseGroup {
      fuse = {};
    };

    # Add user to fuse group if it exists
    users.users.user = mkIf cfg.enableFuseGroup {
      extraGroups = [ "fuse" ];
    };

    # Ensure necessary kernel modules are loaded
    boot.kernelModules = [ "fuse" ];

    # Set up environment for SSHFS
    environment.sessionVariables = {
      # Allow non-root users to specify the allow_other or allow_root mount options
      FUSE_ALLOW_OTHER = mkIf cfg.allowOtherUsers "1";
    };
  };
}