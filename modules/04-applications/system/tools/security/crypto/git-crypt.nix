{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.git-crypt;
in {
  options.maxos.tools.git-crypt = {
    enable = mkEnableOption "git-crypt configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git-crypt
      gnupg  # Required for GPG key management
      pinentry-curses  # Terminal-based PIN entry
      pinentry-gtk2    # GUI-based PIN entry
    ];

    programs.git = {
      enable = true;
      package = pkgs.git;
    };

    # Configure GPG agent with pinentry
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = pkgs.pinentry-curses;  # Use terminal-based pinentry for better compatibility
    };

    # Ensure proper GPG home directory permissions and configuration
    system.activationScripts.gpgSetup = ''
      mkdir -p /home/user/.gnupg
      chown user:users /home/user/.gnupg
      chmod 700 /home/user/.gnupg
      
      # Configure GPG to use pinentry-curses
      echo "pinentry-program ${pkgs.pinentry-curses}/bin/pinentry-curses" > /home/user/.gnupg/gpg-agent.conf
      chown user:users /home/user/.gnupg/gpg-agent.conf
      chmod 600 /home/user/.gnupg/gpg-agent.conf
    '';
  };
}