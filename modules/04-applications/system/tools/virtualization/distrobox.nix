{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.distrobox;

  dependenciesValid =
    config.maxos.user.enable or true;

  hasContainerBackend =
    (config.virtualisation.docker.enable or false)
    || (config.virtualisation.podman.enable or false);

in {
  options.maxos.tools.distrobox = {
    enable = mkEnableOption "distrobox - run Linux distributions as containers integrated with the host";

    package = mkOption {
      type = types.package;
      default = pkgs.distrobox;
      description = "The distrobox package to use";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional distrobox-related packages to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = [ cfg.package ] ++ cfg.extraPackages;

    warnings = mkIf (cfg.enable && !hasContainerBackend) [
      "distrobox needs a container backend. Enable virtualisation.docker or virtualisation.podman before creating boxes."
    ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "distrobox requires user module to be enabled";
      }
    ];
  };
}
