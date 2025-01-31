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
    ../../modules/tools/logseq.nix
    ../../modules/tools/micromamba.nix
    ../../modules/tools/direnv.nix
  ];

  # Enable home-manager and tools
  programs.home-manager.enable = true;
  modules.tools.logseq.enable = true;
  modules.tools.micromamba.enable = true;
  modules.tools.direnv.enable = true;

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

      # Media controls
      playerctl

      # Development tools
      git
      gh
      neovim
      ripgrep
      fd
      jq
      tree
      
      # Java development
      jdk
      maven
      gradle

      # System tools
      htop
      btop
      neofetch
      unzip
      zip
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
      networkmanagerapplet
      arandr
      redshift
      brightnessctl
      pasystray
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

    easyeffects = {
      enable = true;
      preset = "default";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # i3 configuration for G16
  xsession.windowManager.i3.config = {
    workspaceOutputAssign = [
      { workspace = "0: slack"; output = "eDP-1"; }
      { workspace = "1: web"; output = "eDP-1"; }
      { workspace = "2: code"; output = "eDP-1"; }
      { workspace = "3: term"; output = "eDP-1"; }
      { workspace = "4: term"; output = "eDP-1"; }
      { workspace = "5: burp"; output = "eDP-1"; }
      { workspace = "8: logseq"; output = "eDP-1"; }
      { workspace = "9: pw"; output = "eDP-1"; }
    ];
  };
}
