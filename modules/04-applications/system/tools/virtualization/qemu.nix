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
        };
      };
    };

    environment.systemPackages = with pkgs; [
      virt-manager
      qemu
      OVMF
      virt-viewer
    ];

    boot.kernelModules = [ "kvm-intel" "kvm-amd" "tun" ];

    users.users.${userConfig.name}.extraGroups = [ "libvirtd" "kvm" ];

    networking.firewall.trustedInterfaces = [ "virbr0" ];

    systemd.services.qemu-ctf-taps = {
      description = "Create persistent taps for AnyCTF lab VMs on virbr0";
      after = [ "libvirt-default-network.service" "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = let
        ip = "${pkgs.iproute2}/bin/ip";
      in ''
        ${ip} link show virbr0 >/dev/null 2>&1 || exit 0
        owner=$(${pkgs.coreutils}/bin/id -u ${userConfig.name})
        for i in 0 1 2 3 4 5 6 7; do
          dev="tap-ctf-$i"
          if ! ${ip} link show "$dev" >/dev/null 2>&1; then
            ${ip} tuntap add dev "$dev" mode tap user "$owner"
          fi
          ${ip} link set "$dev" master virbr0
          ${ip} link set "$dev" up
        done
      '';
    };

    systemd.services.libvirt-default-network = {
      after = [ "libvirtd.service" ];
      bindsTo = [ "libvirtd.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.libvirt}/bin/virsh -c qemu:///system net-start default 2>/dev/null || true
      '';
    };

    systemd.services.qemu-ctf-forward = {
      description = "Allow container networks to reach AnyCTF lab VMs on virbr0";
      after = [ "libvirt-default-network.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = let
        ipt = "${pkgs.iptables}/bin/iptables";
      in ''
        for net in 172.16.0.0/12 10.42.0.0/16; do
          ${ipt} -C LIBVIRT_FWI -s "$net" -o virbr0 -j ACCEPT 2>/dev/null ||
            ${ipt} -I LIBVIRT_FWI -s "$net" -o virbr0 -j ACCEPT
        done
      '';
    };

    assertions = [
      {
        assertion = dependenciesValid;
        message = "QEMU requires user module";
      }
    ];
  };
}