{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    mcfly  # Shell history search
    grc    # Generic colouriser
    lazygit # Terminal UI for git
    zsh-powerlevel10k  # For p10k command
  ];

  home.file.".p10k.zsh".source = ./zsh/p10k.zsh;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
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
      # Set terminal font
      if [[ "$TERM" == "xterm-256color" || "$TERM" == "screen-256color" || "$TERM" == "alacritty" ]]; then
        POWERLEVEL9K_MODE='nerdfont-complete'
      fi

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

      # Initialize Powerlevel10k with proper font
      if [[ -f ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme ]]; then
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        # Configure basic p10k settings if no config exists
        if [[ ! -f ~/.p10k.zsh ]]; then
          POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
          POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs time)
          POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
          POWERLEVEL9K_MODE='nerdfont-complete'
        fi
      fi
    '';

    initExtra = ''
      # Source p10k config if it exists
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

      # Command execution time tracking and notification
      __cmd_timestamp=0
      
      function preexec() {
        __cmd_timestamp=$SECONDS
      }
      
      function precmd() {
        local exit_code=$?
        local duration=$((SECONDS - __cmd_timestamp))
      }

      # Copy most recent download to current directory
      function cpd() {
        local last_download
        last_download=$(ls -t ~/Downloads | head -1)
        if [[ -n "$last_download" ]]; then
          cp -v ~/Downloads/"$last_download" .
          echo "\nCurrent directory contents:"
          ls -la
        else
          echo "No files found in ~/Downloads"
        fi
      }

      # Copy most recent download to goose workspace
      function cpw() {
        local last_download
        local workspace_dir="/home/user/monorepo/tools/goose/workspace"
        last_download=$(ls -t ~/Downloads | head -1)
        if [[ -n "$last_download" ]]; then
          cp -v ~/Downloads/"$last_download" "$workspace_dir/"
          echo "\nWorkspace directory contents:"
          ls -la "$workspace_dir"
        else
          echo "No files found in ~/Downloads"
        fi
      }
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
