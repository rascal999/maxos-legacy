{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.happy-coder;

  dependenciesValid =
    config.maxos.user.enable or true;

in {
  options.maxos.tools.happy-coder = {
    enable = mkEnableOption "Happy Coder (mobile/web client for Claude Code)";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # Local 1.1.9 package: nixpkgs 0.11.2 hangs codex sessions on MCP tool
    # approvals (slopus/happy#1134, #987). See ./happy-coder/package.nix.
    home.packages = [
      (pkgs.callPackage ./happy-coder/package.nix { })
    ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "happy-coder requires the user module to be enabled";
      }
    ];
  };
}
