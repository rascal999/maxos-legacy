{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/tools/i3/desktop.nix
    ../../modules/tools/tmux.nix
    ../../modules/tools/alacritty.nix
    ../../modules/tools/zsh.nix
    ../../modules/tools/rofi/default.nix
    ../../modules/tools/firefox/default.nix
    ../../modules/tools/vscode.nix
    ../../modules/tools/micromamba.nix
  ];

  # Enable home-manager and tools
  programs.home-manager.enable = true;
  modules.tools.micromamba.enable = true;

  # Home Manager needs a bit of information about you and the paths it should manage
  home = {
    username = "user";
    homeDirectory = lib.mkForce "/home/user";
    stateVersion = "25.05";

    packages = with pkgs; [
      # Fonts
      nerd-fonts.jetbrains-mono

      # Development tools
      git
      neovim
      ripgrep
      tree

      # System tools
      htop
      neofetch
      wget
      curl
      
      # File management
      pcmanfm
      feh
      
      # System monitoring and management
      networkmanagerapplet
      arandr
      redshift
    ];

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
    };

    # File associations
    file = {
      ".config/mimeapps.list".text = ''
        [Default Applications]
        text/html=firefox.desktop
        x-scheme-handler/http=firefox.desktop
        x-scheme-handler/https=firefox.desktop
      '';
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Test User";
    userEmail = "test@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
    };
  };

  # Additional program configurations
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        ".." = "cd ..";
        "..." = "cd ../..";
        update = "sudo nixos-rebuild switch";
        gs = "git status";
        gc = "git commit";
        gp = "git push";
      };
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  # Enable services
  services = {
    picom = {
      enable = true;
      vSync = true;
    };

    dunst = {
      enable = true;
      settings = {
        global = {
          font = "JetBrainsMono Nerd Font 10";
          frame_width = 2;
          frame_color = "#4c566a";
        };
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
