{ config, pkgs, lib, ... }:

{
  imports = [
    ../common/shell.nix      # Shell configuration (zsh, aliases, etc)
    ../common/git.nix        # Git configuration
    ../common/direnv.nix     # direnv for project-specific environments
    ../common/development.nix # Development tools
  ];

  # Basic user packages that should be available everywhere
  home.packages = with pkgs; [
    # System tools
    htop
    btop
    ripgrep
    fd
    tree
    jq
    yq
    
    # Development
    neovim
    tmux
    fzf
    
    # Network tools
    curl
    wget
    whois
    dig
    
    # Archive tools
    zip
    unzip
    p7zip
    
    # Misc
    bat # Better cat
    exa # Better ls
    du-dust # Better du
    duf # Better df
  ];

  # XDG Base Directory specification
  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less -R";
    MANPAGER = "less -R";
  };

  # Manage dotfiles with Home Manager
  home.file = {
    ".editorconfig".text = ''
      root = true

      [*]
      end_of_line = lf
      insert_final_newline = true
      trim_trailing_whitespace = true
      charset = utf-8
      indent_style = space
      indent_size = 2

      [Makefile]
      indent_style = tab

      [*.{nix,ml,exs,ex}]
      indent_size = 2

      [*.{py,rs,go}]
      indent_size = 4
    '';
  };
}
