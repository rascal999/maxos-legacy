{ config, pkgs, ... }:

{
  virtualisation = {
    libvirtd = {
      enable = true;
      networks.default.enable = false;
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

  users.users.user.extraGroups = [ "libvirtd" "kvm" ];
}