{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    mcfly  # Shell history search
    grc    # Generic colouriser
    lazygit # Terminal UI for git
    zsh-powerlevel10k  # For p10k command
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 100000;
      save = 100000;
      path = "$HOME/.local/share/zsh/history";
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true;
      share = false;  # Disable sharing to prevent race conditions
    };

    initExtraFirst = ''
      # History setup and repair (before instant prompt)
      historySetup() {
        local histdir="$HOME/.local/share/zsh"
        local histfile="$histdir/history"
        
        mkdir -p "$histdir" 2>/dev/null
        
        if [[ -f "$histfile" ]] && ! fc -R "$histfile" >/dev/null 2>&1; then
          mv "$histfile" "$histfile.corrupt-$(date +%Y%m%d-%H%M%S)" 2>/dev/null
          touch "$histfile" 2>/dev/null
        fi
        
        [[ -f "$histfile" ]] || touch "$histfile" 2>/dev/null
        chmod 600 "$histfile" 2>/dev/null
      }
      historySetup >/dev/null 2>&1

      # Enable Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Initialize Powerlevel10k
      if [[ -f ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme ]]; then
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      fi

      # Create p10k config if it doesn't exist
      if [[ ! -f ~/.p10k.zsh ]]; then
        cp ${./zsh/p10k.zsh} ~/.p10k.zsh 2>/dev/null
      fi
    '';

    initExtra = ''
      # Source p10k config if it exists
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "colorize" ];
    };

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

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];
  };
}
