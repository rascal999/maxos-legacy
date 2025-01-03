{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.security;
in {
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

    auditd = mkOption {
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

  config = mkIf cfg.enable {
    # SSH Hardening
    services.openssh = mkIf cfg.sshHardening {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
        MaxAuthTries = 3;
      };
    };

    # Firewall Configuration
    networking.firewall = mkIf cfg.firewallEnable {
      enable = true;
      allowedTCPPorts = [ 22 ]; # SSH only by default
      allowPing = false;
      rejectPackets = true;
      logReversePathDrops = true;
    };

    # System Auditing
    security.auditd.enable = cfg.auditd;
    security.audit = mkIf cfg.auditd {
      enable = true;
      rules = [
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/sudoers -p wa -k sudo_log"
        "-a always,exit -F arch=b64 -S execve -k exec_log"
      ];
    };

    # Password Policies
    security.pam = mkIf cfg.strongPasswords {
      services.passwd.pwquality.config = ''
        minlen = 12
        minclass = 3
        maxrepeat = 3
        gecoscheck = 1
        dictcheck = 1
        usercheck = 1
        retry = 3
      '';
    };

    # Additional Security Measures
    boot.kernel.sysctl = {
      # Restrict dmesg access
      "kernel.dmesg_restrict" = 1;
      # Protect against SYN flood attacks
      "net.ipv4.tcp_syncookies" = 1;
      # Protect against time-wait assassination
      "net.ipv4.tcp_rfc1337" = 1;
      # Protect against ICMP redirects
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      # Protect against IP spoofing
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
    };

    environment.systemPackages = with pkgs; [
      aide # File integrity checker
      rkhunter # Rootkit detection
      lynis # Security auditing
      fail2ban # Intrusion prevention
    ];
  };
}
