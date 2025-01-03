{ config, pkgs, lib, ... }:

let
  zshConfigDir = ./zsh;
in {
  # Zsh configuration
  programs.zsh = {
    enable = true;
    autosuggestions.enable = false;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    histSize = 100000;

    # Oh My Zsh configuration
    ohMyZsh = {
      enable = true;
      plugins = [ "colorize" ];
    };


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
    interactiveShellInit = ''
      # Create history directory if it doesn't exist
      mkdir -p ~/.local/share/zsh
      
      # Enable Powerlevel10k theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Source default p10k config if user hasn't customized it
      [[ ! -f ~/.p10k.zsh ]] && cp ${zshConfigDir}/p10k.zsh ~/.p10k.zsh
      source ~/.p10k.zsh

      # Source zshrc
      source ${zshConfigDir}/zshrc.zsh

      # Load plugins
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    '';
  };

  # Ensure required packages are installed
  environment.systemPackages = with pkgs; [
    mcfly  # Shell history search
    grc    # Generic colouriser
    lazygit # Terminal UI for git
    zsh-powerlevel10k  # For p10k command
    xorg.xmodmap  # For keyboard mappings
  ];

  # Set up zsh environment
  system.activationScripts.zshSetup = ''
    # Create zsh history directory
    mkdir -p /home/user/.local/share/zsh
    chown -R user:users /home/user/.local/share/zsh

    # Set up p10k config
    if [[ ! -f /home/user/.p10k.zsh ]]; then
      cp ${zshConfigDir}/p10k.zsh /home/user/.p10k.zsh
      chown user:users /home/user/.p10k.zsh
    fi
  '';
}
