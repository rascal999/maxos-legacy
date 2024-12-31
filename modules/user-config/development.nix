# Development Environment Configuration
#
# This module handles development-specific configurations including:
# - Git configuration
# - Container support (Docker/Podman)
# - Virtualisation
# - Development tools and languages
# - Code editors

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.userConfig;
  types = import ./types.nix { inherit lib; };
in {
  config = mkIf (cfg != null && cfg.development.enable) {
    # System-level development configuration
    virtualisation = mkIf cfg.development.containers.virtualisation {
      # Docker configuration
      docker = {
        enable = cfg.development.containers.enable;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };

      # libvirt/QEMU configuration
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu;
          runAsRoot = false;
        };
      };
    };

    # Add user to relevant groups
    users.users.${cfg.identity.username}.extraGroups = mkIf cfg.development.containers.enable [
      "docker"
      "libvirtd"
    ];

    # Home Manager configuration
    home-manager.users.${cfg.identity.username} = { pkgs, ... }: {
      # Git configuration
      programs.git = mkIf cfg.development.git.enable {
        enable = true;
        userName = lib.mkForce cfg.development.git.userName;
        userEmail = lib.mkForce cfg.development.git.userEmail;
        extraConfig = lib.mkForce {
          core.editor = cfg.development.git.editor;
          init.defaultBranch = "main";
          pull.rebase = false;
          commit = mkIf (cfg.development.git.signingKey != null) {
            gpgSign = true;
            signingKey = cfg.development.git.signingKey;
          };
          alias = {
            st = "status";
            ci = "commit";
            co = "checkout";
            br = "branch";
            unstage = "reset HEAD --";
            last = "log -1 HEAD";
            visual = "!gitk";
          };
        };
        # Useful ignores
        ignores = [
          ".DS_Store"
          "*.swp"
          "*~"
          "*.log"
          ".env"
          ".direnv/"
          "result"
          "result-*"
        ];
      };

      # Development tools and languages
      home.packages = cfg.development.languages ++ cfg.development.editors ++ (with pkgs; [
        # Basic development tools
        gnumake
        gcc
        binutils
        gdb
        
        # Version control
        git
        git-lfs
        
        # Build tools
        cmake
        ninja
        
        # Development utilities
        direnv
        shellcheck
        
        # Documentation
        man-pages
        man-pages-posix
      ]);

      # direnv configuration
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      # Editor configurations
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        defaultEditor = true;
        
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

      programs.vscode = mkIf (builtins.elem pkgs.vscode cfg.development.editors) {
        enable = true;
        extensions = with pkgs.vscode-extensions; [
          # Basic functionality
          vscodevim.vim
          eamodio.gitlens
          
          # Language support
          ms-python.python
          rust-lang.rust-analyzer
          golang.go
          
          # Tools
          ms-azuretools.vscode-docker
          hashicorp.terraform
          
          # Theme
          dracula-theme.theme-dracula
        ];
        userSettings = lib.mkForce {
          "editor.fontFamily" = cfg.desktop.fonts.monospace;
          "editor.fontSize" = 14;
          "editor.lineNumbers" = "relative";
          "editor.renderWhitespace" = "boundary";
          "editor.rulers" = [ 80 120 ];
          "files.trimTrailingWhitespace" = true;
          "files.insertFinalNewline" = true;
          "workbench.colorTheme" = 
            if cfg.desktop.theme.name == "dark"
            then "Dracula"
            else "Default Light+";
        };
      };

      # Shell development environment
      home.sessionVariables = {
        EDITOR = cfg.development.git.editor;
        VISUAL = cfg.development.git.editor;
      };
    };
  };
}
