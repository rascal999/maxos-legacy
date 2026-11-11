{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.krunvm;

  dependenciesValid =
    config.maxos.user.enable or true;

  # krunvm pulls images through buildah's container storage, which reads
  # /etc/containers/policy.json. Ship the upstream containers-common default
  # unless another module (podman, containers) already owns that path.
  policyJson = pkgs.writeText "containers-policy.json" ''
    {
      "default": [{"type": "insecureAcceptAnything"}]
    }
  '';

in {
  options.maxos.tools.krunvm = {
    enable = mkEnableOption "krunvm - run OCI images as lightweight KVM microVMs";

    package = mkOption {
      type = types.package;
      default = pkgs.krunvm;
      description = "The krunvm package to use";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional krunvm-related packages to install";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # buildah provides the container storage backend and the unshare
    # userns wrapper krunvm's rootless store requires.
    environment.systemPackages = [ cfg.package pkgs.buildah ] ++ cfg.extraPackages;

    environment.etc."containers/policy.json" = mkIf
      (!(config.virtualisation.containers.enable or false)) {
      source = policyJson;
      mode = "0644";
    };

    assertions = [
      {
        assertion = dependenciesValid;
        message = "krunvm requires user module to be enabled";
      }
    ];
  };
}
