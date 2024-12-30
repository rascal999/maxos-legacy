{ config, pkgs, lib, ... }:

{
  # Development tools and configurations
  home.packages = with pkgs; [
    # Version Control
    git-lfs
    git-crypt
    
    # Build tools
    gnumake
    cmake
    ninja
    
    # Languages and Runtimes
    nodejs
    python3
    go
    rustup
    
    # Development Tools
    vscode
    docker-compose
    
    # Debug/Analysis
    gdb
    lldb
    strace
    ltrace
    
    # Documentation
    man-pages
    man-pages-posix
    
    # Network Tools
    netcat
    socat
    nmap
    tcpdump
    wireshark
    
    # System Tools
    lsof
    sysstat
    iotop
    
    # Text Processing
    ripgrep
    fd
    jq
    yq
    
    # Security
    gnupg
    age
    ssh-copy-id
  ];

  # VSCode configuration
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      # Theme
      dracula-theme.theme-dracula
      
      # Languages
      bbenoist.nix
      ms-python.python
      golang.go
      rust-lang.rust-analyzer
      
      # Git
      eamodio.gitlens
      
      # Tools
      ms-azuretools.vscode-docker
      redhat.vscode-yaml
      
      # Editor Enhancement
      vscodevim.vim
      editorconfig.editorconfig
    ];
    
    userSettings = {
      "editor.fontFamily" = "'FiraCode Nerd Font', 'Droid Sans Mono', 'monospace'";
      "editor.fontSize" = 14;
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.renderWhitespace" = "boundary";
      "editor.rulers" = [ 80 100 120 ];
      "editor.tabSize" = 2;
      "files.autoSave" = "onFocusChange";
      "terminal.integrated.fontFamily" = "'FiraCode Nerd Font'";
      "workbench.colorTheme" = "Dracula";
      
      # Language specific settings
      "[nix]" = {
        "editor.tabSize" = 2;
        "editor.formatOnSave" = true;
      };
      "[python]" = {
        "editor.tabSize" = 4;
        "editor.formatOnSave" = true;
      };
      "[rust]" = {
        "editor.tabSize" = 4;
        "editor.formatOnSave" = true;
      };
      "[go]" = {
        "editor.tabSize" = 4;
        "editor.formatOnSave" = true;
      };
    };
  };

  # Neovim configuration
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    
    extraConfig = ''
      " Basic Settings
      set number
      set relativenumber
      set expandtab
      set shiftwidth=2
      set tabstop=2
      set smartindent
      set termguicolors
      set ignorecase
      set smartcase
      set mouse=a
      set clipboard+=unnamedplus
      
      " Key mappings
      let mapleader = " "
      nnoremap <leader>ff <cmd>Telescope find_files<cr>
      nnoremap <leader>fg <cmd>Telescope live_grep<cr>
      nnoremap <leader>fb <cmd>Telescope buffers<cr>
      nnoremap <leader>fh <cmd>Telescope help_tags<cr>
    '';
    
    plugins = with pkgs.vimPlugins; [
      # Theme
      dracula-vim
      
      # Status Line
      vim-airline
      vim-airline-themes
      
      # Git
      vim-fugitive
      vim-gitgutter
      
      # File Navigation
      telescope-nvim
      nvim-tree-lua
      
      # LSP
      nvim-lspconfig
      nvim-cmp
      
      # Syntax
      vim-nix
      vim-go
      rust-vim
    ];
  };

  # SSH configuration
  programs.ssh = {
    enable = true;
    
    extraConfig = ''
      AddKeysToAgent yes
      
      Host github.com
        User git
        IdentityFile ~/.ssh/github
        
      Host gitlab.com
        User git
        IdentityFile ~/.ssh/gitlab
    '';
  };

  # GPG configuration
  programs.gpg = {
    enable = true;
    settings = {
      default-key = ""; # Set in machine-specific config
      keyserver = "hkps://keys.openpgp.org";
    };
  };
}
