{ config, lib, pkgs, ... }:

{
  imports = [
    # ../../modules/home-profiles/development.nix  # Disabled - imports hybrid modules that conflict with layered structure
    # ../../modules/tools/claude-code.nix  # Disabled - hybrid module conflicts with layered structure
    # ../../modules/package-bundles/default.nix  # Temporarily disabled due to environment option error
  ];

  # Development profile provides base configuration
  # Package bundles provide common package sets
  # maxos.packageBundles = {
  #   enable = true;
  #   developmentBundle = true;
  #   installTarget = "home";
  # };
  
  # Additional tool-specific configuration below
  
  # Enable individual tools that need home-manager configuration
  # Note: Hybrid modules disabled - using pure home-manager or system-only modules
  maxos.tools = {
    # Terminal and shell
    zsh.enable = true;
    alacritty.enable = true;
    tmux.enable = true;
    
    # Window manager
    i3.enable = true;
    
    # Development tools
    vscode.enable = true;
    direnv.enable = true;
    
    # Applications
    firefox.enable = true;
    logseq.enable = true;
    remmina.enable = true;
  };

  # Home Manager needs a bit of information about you and the paths it should manage
  home = {
    username = "user";
    homeDirectory = lib.mkForce "/home/user";
    stateVersion = lib.mkForce "25.05";  # Please read the comment below

    # The home.stateVersion option does not have a default and must be set
    # First time users of home-manager should read:
    # https://nix-community.github.io/home-manager/index.html#sec-install-standalone

    packages = with pkgs; [
      # Packages provided by developmentBundle via package-bundles
      # Additional packages not in bundles:
      aider-chat
      openai-whisper
      
      # Fonts now managed centrally via maxos.fonts
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

  # i3 configuration for G16
  xsession.windowManager.i3.config = {
    workspaceOutputAssign = [
      { workspace = "0: slack"; output = "eDP-1"; }
      { workspace = "1: web"; output = "eDP-1"; }
      { workspace = "2: wcode"; output = "eDP-1"; }
      { workspace = "3: pcode"; output = "eDP-1"; }
      { workspace = "4: term"; output = "eDP-1"; }
      { workspace = "5: burp"; output = "eDP-1"; }
      { workspace = "6: goose"; output = "eDP-1"; }
      { workspace = "8: logseq"; output = "eDP-1"; }
      { workspace = "9: pw"; output = "eDP-1"; }
    ];
  };
}
