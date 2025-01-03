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
        file = "powerlevel10k.zsh-theme";
        name = "powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k";
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
      # Source zshrc
      source ${zshConfigDir}/zshrc.zsh
      
      # Source p10k config
      source ${zshConfigDir}/p10k.zsh
    '';
  };

  # Ensure required packages are installed
  environment.systemPackages = with pkgs; [
    mcfly  # Shell history search
    grc    # Generic colouriser
    lazygit # Terminal UI for git
  ];
}
