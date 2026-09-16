{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.packer;

  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;

in {
  options.maxos.packer = {
    enable = mkEnableOption "HashiCorp Packer for machine image builds";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      packer
    ];

    assertions = [
      {
        assertion = config.maxos.qemu.enable or true;
        message = "packer module requires the qemu module for the QEMU builder";
      }
    ];
  };
}