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
      nerd-fonts.jetbrains-mono
      nerd-fonts.meslo-lg

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
      pwgen
      aider-chat
      openai-whisper
      
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

    # File associations and scripts
    file = {
      ".screenlayout/dual-monitor.sh" = {
        executable = true;
        text = ''
          #!/bin/sh
          xrandr --output DP-2 --primary --mode 3440x1440 --rate 144 --pos 0x0 --output DP-4 --mode 2560x1440 --rate 144 --right-of DP-2
        '';
      };
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

      # Make the Stacey Assistant script available and executable
      ".local/bin/start-stacey-assistant" = {
        source = ../../scripts/start-stacey-assistant.sh; # Path relative to this home.nix file
        executable = true;
      };
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

  # Systemd user service for Stacey Assistant
  systemd.user.services.stacey-assistant = {
    Unit = {
      Description = "Stacey Assistant Service";
      # Start after the graphical session is ready, adjust if network is needed earlier
      After = [ "graphical-session.target" ];
    };
    Service = {
      # Execute the script using bash from Nix packages
      ExecStart = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.local/bin/start-stacey-assistant";
      Restart = "on-failure"; # Restart the service if it fails
      RestartSec = "10s";      # Wait 10 seconds before restarting
    };
    Install = {
      WantedBy = [ "graphical-session.target" ]; # Ensure it's started with the user session
    };
  };

  # User service for Push-to-Talk
  # Note: Ensure the user 'user' is part of the 'input' group at the system level
  # (e.g., in users.nix: users.users.user.extraGroups = [ "input" ];)
  # for /dev/input/event* access needed by the python-ptt.py script.

  # i3 configuration for rig
  xsession.windowManager.i3.config = {
    # Monitor setup in startup
    startup = [
      { command = "$HOME/.screenlayout/dual-monitor.sh"; notification = false; }
      { command = "i3-msg 'debuglog on; shmlog on; shmlog size 26214400'"; notification = false; }
    ];

    # Workspace monitor assignments
    workspaceOutputAssign = [
      # Left monitor - Communication
      { workspace = "0: slack"; output = "DP-4"; }
      # All other workspaces on ultrawide
      { workspace = "1: web"; output = "DP-2"; }
      { workspace = "2: wcode"; output = "DP-2"; }
      { workspace = "3: pcode"; output = "DP-2"; }
      { workspace = "4: term"; output = "DP-2"; }
      { workspace = "5: burp"; output = "DP-2"; }
      { workspace = "6: goose"; output = "DP-2"; }
      { workspace = "8: logseq"; output = "DP-2"; }
      { workspace = "9: pw"; output = "DP-2"; }
    ];
  };
}
