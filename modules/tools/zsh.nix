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
      share = true;
    };

    initExtra = ''
      # Create history directory
      mkdir -p "$(dirname "$HISTFILE")"
      
      # History locking settings
      typeset -g HISTFILE_LOCK="$HISTFILE.lock"
      typeset -g HISTFILE_LOCK_TIMEOUT=5
      
      # Function to lock history file
      _zsh_lock_histfile() {
        local lockfile="$HISTFILE_LOCK"
        if ! mkdir "$lockfile" 2>/dev/null; then
          if [ $(($(date +%s) - $(stat -c %Y "$lockfile"))) -gt $HISTFILE_LOCK_TIMEOUT ]; then
            rm -rf "$lockfile"
            mkdir "$lockfile" 2>/dev/null || return 1
          else
            return 1
          fi
        fi
        return 0
      }
      
      # Function to unlock history file
      _zsh_unlock_histfile() {
        rm -rf "$HISTFILE_LOCK"
      }
      
      # Add hooks for history file locking
      autoload -Uz add-zsh-hook
      add-zsh-hook zshexit _zsh_unlock_histfile
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
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
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
