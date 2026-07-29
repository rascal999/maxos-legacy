{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.uv;

  dependenciesValid =
    config.maxos.user.enable or true;

in {
  options.maxos.tools.uv = {
    enable = mkEnableOption "uv - fast Python package manager and project manager";

    package = mkOption {
      type = types.package;
      default = pkgs.uv;
      description = "The uv package to use";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional uv-related packages to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;

    assertions = [
      {
        assertion = dependenciesValid;
        message = "uv requires user module to be enabled";
      }
    ];
  };
}