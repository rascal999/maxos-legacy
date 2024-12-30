{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    
    # History configuration
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      share = true;
      extended = true;
    };

    # Initialize completion system
    initExtra = ''
      # Better completion
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      
      # Load and initialize the completion system
      autoload -Uz compinit
      compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
      
      # Better directory navigation
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_MINUS
      
      # History improvements
      setopt EXTENDED_HISTORY
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      
      # Useful options
      setopt INTERACTIVE_COMMENTS
      setopt RC_QUOTES
      unsetopt FLOW_CONTROL
      
      # Key bindings
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line
      bindkey "^[[3~" delete-char
      bindkey "^H" backward-delete-char
    '';

    # Shell aliases
    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      
      # Better defaults
      ls = "exa";
      ll = "exa -l";
      la = "exa -la";
      cat = "bat";
      du = "dust";
      df = "duf";
      
      # Git shortcuts
      g = "git";
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gd = "git diff";
      gl = "git log";
      gs = "git status";
      
      # Nix shortcuts
      n = "nix";
      ns = "nix shell";
      nd = "nix develop";
      nb = "nix build";
      nf = "nix flake";
      
      # NixOps shortcuts
      nop = "nixops";
      nopd = "nixops deploy";
      nopi = "nixops info";
      nopl = "nixops list";
      
      # System
      sc = "sudo systemctl";
      jc = "journalctl";
      
      # Misc
      mkdir = "mkdir -p";
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
    };

    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "kubectl"
        "sudo"
        "command-not-found"
      ];
      theme = "robbyrussell";
    };
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      nix_shell = {
        symbol = " ";
        format = "[$symbol$state]($style) ";
      };
    };
  };

  # Useful shell tools
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    
    tmux = {
      enable = true;
      shortcut = "a";
      terminal = "screen-256color";
      historyLimit = 10000;
      keyMode = "vi";
    };
  };
}
