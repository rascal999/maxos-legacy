{ config, lib, ... }:

with lib;

{
  imports = [
    ./audit.nix
    ./firewall.nix
    ./kernel.nix
    ./login.nix
    ./packages.nix
    ./ssh.nix
  ];

  options.security = {
    enable = mkEnableOption "security hardening";

    sshHardening = mkOption {
      type = types.bool;
      default = true;
      description = "Enable SSH security hardening";
    };

    firewallEnable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable firewall with secure defaults";
    };

    enableAudit = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system auditing with auditd";
    };

    strongPasswords = mkOption {
      type = types.bool;
      default = true;
      description = "Enable strong password policies";
    };
  };
}
