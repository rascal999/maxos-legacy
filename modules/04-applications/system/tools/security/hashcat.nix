{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.hashcat;

  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;

  # The NVIDIA ICD lives in /run/opengl-driver, populated by
  # hardware.graphics (nvidia.nix enables it). Only assert on hosts
  # that opt into the OpenCL backend.
  openCLAvailable =
    (config.hardware.graphics.enable or false)
    || (config.hardware.nvidia.modesetting.enable or false);

in {
  options.maxos.tools.hashcat = {
    enable = mkEnableOption "hashcat - GPU-accelerated password recovery";

    withOpenCL = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Keep the OpenCL backend enabled. The NVIDIA ICD is provided by
        /run/opengl-driver (hardware.nvidia + hardware.graphics), so no
        extra packages are needed here.
      '';
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      hashcat
    ];

    assertions = [
      {
        assertion = dependenciesValid;
        message = "hashcat requires the user module to be configured";
      }
      {
        assertion = !cfg.withOpenCL || openCLAvailable;
        message = "hashcat with OpenCL expects hardware.graphics (or the NVIDIA driver) to provide an OpenCL ICD";
      }
    ];
  };
}
