{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.security;
in {
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      aide    # File integrity checker
      lynis   # Security auditing
      fail2ban # Intrusion prevention
    ];
  };
}
