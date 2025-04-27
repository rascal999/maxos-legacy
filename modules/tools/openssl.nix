{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.openssl;
in {
  options.modules.tools.openssl = {
    enable = mkEnableOption "OpenSSL tools and libraries";
    
    installDevelopmentPackages = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install OpenSSL development packages";
    };
  };

  config = mkIf cfg.enable {
    # Install OpenSSL packages
    environment.systemPackages = with pkgs; [
      # Core OpenSSL package
      openssl
      
      # Development packages if enabled
      (mkIf cfg.installDevelopmentPackages openssl.dev)
      (mkIf cfg.installDevelopmentPackages openssl.out)
    ];

    # Set environment variables for OpenSSL
    environment.sessionVariables = {
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
    };
    
    # Add OpenSSL to system SSL certificates
    security.pki.certificates = [];
  };
}