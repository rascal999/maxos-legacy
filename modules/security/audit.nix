{ config, lib, ... }:

with lib;

let
  cfg = config.security;
in {
  config = mkIf (cfg.enable && cfg.enableAudit) {
    security.auditd.enable = true;
    security.audit = {
      enable = true;
      rules = [
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/sudoers -p wa -k sudo_log"
        "-a always,exit -F arch=b64 -S execve -k exec_log"
      ];
    };
  };
}
