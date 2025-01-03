{ config, lib, ... }:

with lib;

let
  cfg = config.security;
in {
  config = mkIf cfg.enable {
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
  };
}
