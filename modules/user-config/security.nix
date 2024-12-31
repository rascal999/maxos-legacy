# Security Configuration
#
# This module handles security-specific configurations including:
# - GPG setup
# - YubiKey integration
# - Firewall rules
# - PAM authentication

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userConfig;
  types = import ./types.nix { inherit lib; };
in {
  config = mkIf (cfg != null) {
    # System-level security configuration
    security = {
      # PAM configuration
      pam = {
        # YubiKey authentication
        yubico = mkIf cfg.security.yubikey.enable {
          enable = true;
          debug = false;
          mode = "challenge-response";
          control = "required";
        };
      };
    };

    # Firewall configuration
    networking.firewall = mkIf cfg.security.firewall.enable {
      enable = true;
      allowedTCPPorts = cfg.security.firewall.allowedTCPPorts;
      allowedUDPPorts = cfg.security.firewall.allowedUDPPorts;
      # Common additional settings
      allowPing = true;
      logReversePathDrops = true;
      # Automatically allow related traffic
      extraCommands = ''
        ip46tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      '';
    };

    # Home Manager configuration
    home-manager.users.${cfg.identity.username} = { pkgs, ... }: {
      # GPG configuration
      programs.gpg = mkIf cfg.security.gpg.enable {
        enable = true;
        settings = {
          # Use AES256, 192, or 128 as cipher
          personal-cipher-preferences = "AES256 AES192 AES";
          # Use SHA512, 384, or 256 as digest
          personal-digest-preferences = "SHA512 SHA384 SHA256";
          # Use ZLIB, BZIP2, ZIP, or no compression
          personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
          # Default preferences for new keys
          default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
          # SHA512 as digest to sign keys
          cert-digest-algo = "SHA512";
          # SHA512 as digest for symmetric ops
          s2k-digest-algo = "SHA512";
          # AES256 as cipher for symmetric ops
          s2k-cipher-algo = "AES256";
          # UTF-8 support for compatibility
          charset = "utf-8";
          # Show Unix timestamps
          fixed-list-mode = true;
          # No comments in signature
          no-comments = true;
          # No version in signature
          no-emit-version = true;
          # Long hexidecimal key format
          keyid-format = "0xlong";
          # Display UID validity
          list-options = "show-uid-validity";
          verify-options = "show-uid-validity";
          # Display all keys and their fingerprints
          with-fingerprint = true;
          # Display key origins and updates
          with-key-origin = true;
          # Cross-certify subkeys are present and valid
          require-cross-certification = true;
          # Disable caching of passphrase for symmetrical ops
          no-symkey-cache = true;
          # Enable smartcard
          use-agent = true;
        };
      };

      # GPG agent configuration
      services.gpg-agent = mkIf cfg.security.gpg.enable {
        enable = true;
        enableSshSupport = true;
        defaultCacheTtl = 1800;
        maxCacheTtl = 7200;
        # PIN entry program
        pinentryFlavor = "gtk2";
      };

      # SSH configuration for GPG/YubiKey
      programs.ssh = mkIf (cfg.security.gpg.enable || cfg.security.yubikey.enable) {
        enable = true;
        extraConfig = ''
          # Use GPG agent for SSH keys
          ${optionalString cfg.security.gpg.enable ''
            Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
          ''}
          # YubiKey settings
          ${optionalString cfg.security.yubikey.enable ''
            PKCS11Provider ${pkgs.yubico-piv-tool}/lib/libykcs11.so
          ''}
        '';
      };

      # Security-related packages
      home.packages = with pkgs; [
        # GPG tools
        gnupg
        pinentry-gtk2
        
        # YubiKey tools
        yubikey-manager
        yubico-piv-tool
        
        # Password management
        pass
        pwgen
        
        # Security tools
        openssl
        age
      ];
    };
  };
}
