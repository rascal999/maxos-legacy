{ config, pkgs, lib, ... }:

let
  zshConfigDir = ./zsh;
in {
  # Zsh configuration
  programs.zsh = {
    enable = true;
    autosuggestion.enable = false;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    # Directory hashes for quick navigation
    dirHashes = {
      dl = "$HOME/Downloads";
    };

    # History configuration
    history = {
      size = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [ "colorize" ];
    };

    # Zsh plugins
    plugins = with pkgs; [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "v0.7.1";
          sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
        };
      }
      {
        name = "powerlevel10k";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "v1.19.0";  # Use the latest stable version
          sha256 = "sha256-U5wDGXYyUvFsE2w6QSdGvjufwjUzqjg6WGBwXPmCxUY=";
        };
      }
    ];

    # Shell aliases
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      dig = "grc dig";
      id = "grc id";
      ps = "grc ps";
      lg = "lazygit";
      ff = "firefox";
      ls = "grc ls";
    };

    # Load custom configuration files
    initExtra = ''
      # Enable Powerlevel10k theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Source default p10k config if user hasn't customized it
      [[ ! -f ~/.p10k.zsh ]] && cp ${zshConfigDir}/p10k.zsh ~/.p10k.zsh
      source ~/.p10k.zsh

      # Source zshrc
      source ${zshConfigDir}/zshrc.zsh
    '';
  };

  # Ensure required packages are installed
  environment.systemPackages = with pkgs; [
    mcfly  # Shell history search
    grc    # Generic colouriser
    lazygit # Terminal UI for git
    zsh-powerlevel10k  # For p10k command
  ];

  # Set permissions for p10k config
  system.activationScripts.p10kConfig = ''
    if [[ ! -f /home/user/.p10k.zsh ]]; then
      cp ${zshConfigDir}/p10k.zsh /home/user/.p10k.zsh
      chown user:users /home/user/.p10k.zsh
    fi
  '';
}
