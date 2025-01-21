{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/tools/i3/desktop.nix
    ../../modules/tools/tmux.nix
    ../../modules/tools/alacritty.nix
    ../../modules/tools/zsh.nix
    ../../modules/tools/rofi/default.nix
    ../../modules/tools/firefox/default.nix
  ];

  # Enable home-manager and NUR
  programs.home-manager.enable = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
      url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
      sha256 = "18k6g7cnnzma61lnz1589fcgiagkwab16k6jck7z6p82yg7dvp7s";
    }) {
      inherit pkgs;
    };
  };

  # Home Manager needs a bit of information about you and the paths it should manage
  home = {
    username = "user";
    homeDirectory = lib.mkForce "/home/user";
    stateVersion = "24.11";  # Please read the comment below

    # The home.stateVersion option does not have a default and must be set
    # First time users of home-manager should read:
    # https://nix-community.github.io/home-manager/index.html#sec-install-standalone

    packages = with pkgs; [
      # Fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" "Meslo" ]; })
      
      # Development tools
      git
      gh
      vscode
      neovim
      ripgrep
      fd
      jq
      tree

      # System tools
      htop
      btop
      neofetch
      unzip
      wget
      curl

      libreoffice
      vlc
      gimp
      
      # Communication
      slack
      discord
      
      # File management
      pcmanfm
      ranger
      feh
      
      # System monitoring and management
      pavucontrol
      networkmanagerapplet
      arandr
      redshift
      brightnessctl
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
        application/pdf=org.pwmt.zathura.desktop
      '';
      
      ".Xresources".text = ''
        Xft.dpi: 168
      '';
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
    };
  };

  # Additional program configurations
  programs = {
    vscode = {
      enable = true;
      userSettings = {
        "terminal.integrated.defaultProfile.linux" = "bash";
      };
    };

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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
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
