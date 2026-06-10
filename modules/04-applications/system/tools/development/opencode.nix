{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.opencode;

  opencodePkg = pkgs.writeShellScriptBin "opencode" ''
    exec ${pkgs.nodejs}/bin/npx --yes opencode-ai "$@"
  '';
in {
  options.maxos.tools.opencode = {
    enable = mkEnableOption "opencode (OpenCode CLI)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      opencodePkg
      pkgs.nodejs
    ];

    # Enable nix-ld to run dynamically linked unpatched binaries (like the precompiled binary bundled in opencode-ai)
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      curl
    ];
  };
}
