{ config, lib, pkgs, ... }:

# MaxOS Supabase CLI Tool Module (Layer 4 - Applications)
#
# This module provides the Supabase CLI for managing Supabase projects,
# following layered architecture conventions.

with lib;

let
  cfg = config.maxos.tools.supabase-cli;

  dependenciesValid =
    config.maxos.user.enable or true;

in {
  options.maxos.tools.supabase-cli = {
    enable = mkEnableOption "Supabase CLI command line interface";

    package = mkOption {
      type = types.package;
      default = pkgs.supabase-cli;
      description = "Supabase CLI package to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS supabase-cli tool requires user module to be enabled";
      }
    ];

    environment.systemPackages = [
      cfg.package
    ];
  };
}
