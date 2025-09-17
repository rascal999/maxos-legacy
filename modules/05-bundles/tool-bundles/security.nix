{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.toolBundles.security;
in {
  options.modules.toolBundles.security = {
    enable = mkEnableOption "Security tools bundle";
    
    enableAll = mkOption {
      type = types.bool;
      default = false;
      description = "Enable all security tools";
    };
    
    scanners = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable security scanners (Trivy, Semgrep, Syft, Grype)";
    };
    
    crypto = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable cryptographic tools (OpenSSL)";
    };
    
    monitoring = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable security monitoring tools";
    };
    
    passwordManagement = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable password management (KeePassXC)";
    };
  };

  config = mkIf cfg.enable {
    maxos.tools = {
      # Security scanners
      trivy.enable = mkIf cfg.scanners true;
      semgrep.enable = mkIf cfg.scanners true;
      syft.enable = mkIf cfg.scanners true;
      grype.enable = mkIf cfg.scanners true;
      
      # Cryptographic tools
      openssl.enable = mkIf cfg.crypto true;
      
      # Password management
      keepassxc.enable = mkIf cfg.passwordManagement true;
    };
  };
}