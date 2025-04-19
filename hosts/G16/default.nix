{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ./boot.nix
    ./nvidia.nix
    ./rog.nix
    ./audio.nix
    ./power.nix
    ../../modules/security/default.nix
    ../../modules/desktop/default.nix
    ../../modules/hardware/network.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/tools/syncthing.nix
    ../../modules/scripts/default.nix
    ../../modules/tools/docker.nix  # Import Docker module
    ../../modules/tools/wireguard.nix  # Import WireGuard module
    ../../modules/tools/qemu.nix  # Import QEMU module
    ../../modules/tools/npm.nix  # Import npm module
    ../../modules/tools/traefik.nix  # Import Traefik module
    ../../modules/tools/postman.nix  # Import Postman module
    ../../modules/tools/llm/default.nix  # Import LLM modules (fabric-ai, open-webui, and ollama)
    ../../modules/tools/git-crypt.nix  # Import git-crypt module
    ../../modules/tools/simplescreenrecorder.nix  # Import SimpleScreenRecorder module
    #../../modules/tools/mongodb.nix  # Import MongoDB module
    ../../modules/tools/grafana.nix  # Import Grafana module
    ../../modules/tools/golang.nix  # Import Golang module
    ../../modules/tools/kiwix.nix  # Import Kiwix module
    ../../modules/tools/restic.nix  # Import restic backup module
    ../../modules/tools/gitleaks.nix  # Import Gitleaks module
    ../../modules/tools/remmina.nix  # Import Remmina module
    ../../modules/tools/k3s.nix  # Import k3s module
  ];

  # Enable tools
  modules.tools = {
    postman.enable = true;
    npm.enable = true;
    traefik.enable = false;  # Disable standalone Traefik to use k3s built-in one
    fabric-ai.enable = true;
    git-crypt.enable = true;
    #mongodb = {
    #  enable = true;         # Enable MongoDB
    #  compass.enable = true;  # Enable MongoDB Compass GUI
    #};
    grafana.enable = false;  # Disable Grafana
    golang.enable = true;    # Enable Golang
    kiwix.enable = true;     # Enable Kiwix
    gitleaks = {
      enable = true;         # Enable Gitleaks for secret scanning
      installGitHook = true; # Install pre-push git hook globally
    };
    restic = {
      enable = true;         # Enable restic backup
      hostSubdir = "G16";    # Store backups in G16 subdirectory
    };
    remmina.enable = true;   # Enable Remmina
    k3s = {
      enable = true;
      role = "server";  # Configure as a server (control plane)
      extraFlags = [
        "--disable-cloud-controller"  # Disable cloud controller as this is a local setup
      ];
    };
  };

  # Enable Open WebUI
  modules.tools.open-webui.enable = true;

  # Enable AnythingLLM
  modules.tools.anythingllm = {
    enable = true;
    port = 3001;
    # Don't specify openRouterApiKeyFile to avoid circular dependency
    # The API key can be added directly to /var/lib/anythingllm/openrouter_api_key
  };

  # Enable SimpleScreenRecorder
  modules.tools.simplescreenrecorder.enable = true;

  # Disable system-wide Firefox
  programs.firefox.enable = false;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable security module with default settings
  security = {
    enable = true;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICjMXN/z0u4Sf/+ODpG49ZFBNHqcZFxNgFhTts1GAJrr user@nixos"  # rig's key
    ];
  };

  # Set hostname
  networking.hostName = "G16";
  
  # Add hosts entries
  networking.hosts = {
    "127.0.0.1" = [ "management-api.local" ];
  };

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

  # Touchpad configuration
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = false;
      disableWhileTyping = true;
      scrollMethod = "twofinger";
      tapping = true;
      tappingDragLock = false;
    };
  };

  # Add required packages
  environment.systemPackages = with pkgs; [
    # AppImage support
    appimage-run

    # Docker tools
    docker-compose

    # Graphics utilities
    glxinfo
    xorg.xrandr
    # Backlight utilities
    light
    acpilight
    # NVIDIA tools
    nvidia-docker
    nvidia-container-toolkit
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
    # Qt theming
    libsForQt5.qt5ct
    adwaita-qt
    python311
    vegeta  # HTTP load testing tool
    nmap    # Network scanning tool
    
    # Security tools
    ffuf     # Web fuzzer tool
    testssl  # TLS/SSL testing tool
  ];

  # Add user to video group for backlight control and enable FUSE
  users.users.user.extraGroups = [ "video" ];

  # Enable FUSE for AppImage support
  boot.supportedFilesystems = [ "fuse" ];
  boot.kernelModules = [ "fuse" ];

  # Disable Redshift service to avoid conflicts
  services.redshift.enable = false;

  # Enable NVIDIA support for Docker
  virtualisation.docker.enableNvidia = true;

  # Enable home-manager
  home-manager = {
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
        HOST = config.networking.hostName;
      };
    };
  };

  # Configure 16GB swap file
  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024; # 16GB in MiB
    }
  ];

  # Set system state version
  system.stateVersion = "24.11";
}
