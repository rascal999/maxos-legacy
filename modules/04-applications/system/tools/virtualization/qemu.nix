{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.qemu;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
  userConfig = config.maxos.user;
  
in {
  options.maxos.qemu = {
    enable = mkEnableOption "QEMU virtualization";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu;
          swtpm.enable = true;
          ovmf.enable = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      virt-manager
      qemu
      OVMF
      virt-viewer
    ];

    boot.kernelModules = [ "kvm-intel" "kvm-amd" ];

    users.users.${userConfig.name}.extraGroups = [ "libvirtd" "kvm" ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "QEMU requires user module";
      }
    ];
  };
}