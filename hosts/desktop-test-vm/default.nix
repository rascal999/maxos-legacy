{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ../../modules/security/default.nix
    ../../modules/desktop/default.nix
    ../../modules/tools/npm.nix  # Import npm module
    ../../modules/tools/openai-whisper.nix  # Import openai-whisper module
  ];

  # Enable npm module
  modules.tools.npm.enable = true;
  
  # Enable openai-whisper module
  modules.tools.openai-whisper = {
    enable = true;
    models = [ "base" "small" ];  # Download base and small models
  };

  # Disable system-wide Firefox
  programs.firefox.enable = false;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable security module with default settings
  security.enable = true;

  # X11 configuration
  services.xserver = {
    enable = true;

    # Window manager configuration
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
    };

    # Keyboard layout
    xkb = {
      layout = "gb";
      variant = "dvorakukp";
      options = "terminate:ctrl_alt_bksp";
    };

    # Display manager configuration
    displayManager.lightdm = {
      enable = true;
      background = "#000000";
      greeters.gtk = {
        enable = true;
        theme.name = "Adwaita-dark";
      };
    };
  };

  # Display manager session configuration
  services.displayManager.defaultSession = "none+i3";

  # Configure networking and SSH for VM
  networking = {
    useDHCP = true;  # Use DHCP for VM
    wireless.enable = false;  # Disable wireless
    networkmanager.enable = false;  # Disable NetworkManager in VM
  };

  # Enable SSH with password auth
  services.openssh = {
    enable = true;
    startWhenNeeded = false;  # Start SSH immediately
    settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = lib.mkForce true;
      ListenAddress = "0.0.0.0";  # Listen on all interfaces
    };
  };

  # Ensure SSH starts on boot
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

  # Add required packages
  environment.systemPackages = with pkgs; [
    # Graphics utilities
    glxinfo
    xorg.xrandr
    # Qt theming
    libsForQt5.qt5ct
    adwaita-qt
    # Security tools
    sqlmap
    mitmproxy
    vegeta  # HTTP load testing tool
  ];

  # Enable home-manager with backup support
  home-manager = {
    backupFileExtension = "hm-bak-2024";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.user = { pkgs, ... }: {
      imports = [
        ./home.nix
        ../../modules/tools/i3/desktop.nix
        ../../modules/tools/alacritty.nix
        ../../modules/tools/zsh.nix
      ];

      # GTK configuration
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.adwaita-icon-theme;
        };
        iconTheme = {
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = true;
        };
      };

      # Qt configuration
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style = {
          name = "adwaita-dark";
          package = pkgs.adwaita-qt;
        };
      };

      # Environment variables
      home.sessionVariables = {
        GTK_THEME = "Adwaita:dark";
        QT_QPA_PLATFORMTHEME = "qt5ct";
      };
    };
  };

  # VM-specific configuration
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192; # MB
      cores = 8;
      graphics = true;
      qemu.networkingOptions = [
        "-nic user,model=virtio,hostfwd=tcp::2222-:22"
      ];
    };
  };

  # Set system state version
  system.stateVersion = "24.11";
}
