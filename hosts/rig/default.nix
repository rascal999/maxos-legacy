{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ./boot.nix
    ./nvidia.nix
    ./audio.nix
    ./monitors.nix
    ../../modules/security/default.nix
    ../../modules/desktop/default.nix
    ../../modules/hardware/network.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/tools/syncthing.nix
    ../../modules/tools/llm/default.nix
    ../../modules/tools/docker.nix  # Import Docker module
    ../../modules/tools/wireguard.nix  # Import WireGuard module
    ../../modules/tools/qemu.nix  # Import QEMU module
    ../../modules/tools/rocketchat.nix  # Import Rocket.Chat module
    ../../modules/tools/npm.nix  # Import npm module
    ../../modules/tools/traefik.nix  # Import Traefik module
    ../../modules/tools/postman.nix  # Import Postman module
    ../../modules/tools/git-crypt.nix  # Import git-crypt module
    ../../modules/tools/simplescreenrecorder.nix  # Import SimpleScreenRecorder module
    ../../modules/tools/mongodb.nix  # Import MongoDB module
    ../../modules/tools/grafana.nix  # Import Grafana module
    ../../modules/tools/golang.nix  # Import Golang module
    ../../modules/tools/restic.nix  # Import restic backup module
    ../../modules/tools/gitleaks.nix  # Import Gitleaks module
    ../../modules/tools/remmina.nix  # Import Remmina module
    ../../modules/tools/k3s.nix  # Import k3s module
    ../../modules/tools/dnsmasq.nix  # Import dnsmasq module for DNS resolution
    ../../modules/tools/openssl.nix  # Import OpenSSL module
  ];

  # Enable tools
  modules.tools = {
    postman.enable = true;
    npm.enable = true;
    traefik.enable = false;  # Disable standalone Traefik to use k3s built-in one
    fabric-ai.enable = true;
    git-crypt.enable = true;
    mongodb = {
      enable = true;        # Enable MongoDB
      compass.enable = true; # Enable MongoDB Compass GUI
    };
    grafana.enable = false;  # Disable Grafana
    golang.enable = true;   # Enable Golang
    gitleaks = {
      enable = true;        # Enable Gitleaks for secret scanning
      installGitHook = true; # Install pre-push git hook globally
    };
    restic = {
      enable = true;        # Enable restic backup
      hostSubdir = "rig";   # Store backups in rig subdirectory
    };
    remmina.enable = true;  # Enable Remmina
    k3s = {
      enable = true;
      role = "server";  # Configure as a server (control plane)
      extraFlags = [
        "--disable-cloud-controller"  # Disable cloud controller as this is a local setup
      ];
    };
    dnsmasq = {
      enable = true;
      testDomains = true;    # Enable *.test domain resolution to 127.0.0.1
    };
    openssl = {
      enable = true;
      installDevelopmentPackages = true;  # Install development packages
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

  # Enable Rocket.Chat service
  services.rocketchat = {
    enable = true;
    port = 3200;  # Use port 3200 to avoid conflicts
  };

  # Disable system-wide Firefox
  programs.firefox.enable = false;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable security module with default settings
  security = {
    enable = true;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKy1zrCNG5lCnBXaZwgyUgt5Yd01j695xBSgdoJXKrY1 user@nixos"  # G16's key
    ];
  };

  # Set hostname
  networking.hostName = "rig";
  
  # Add hosts entries
  networking.hosts = {
    "127.0.0.1" = [ "management-api.fisheye.local" "auth-service.fisheye.local" ];
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

  # Add required packages
  environment.systemPackages = with pkgs; [
    # AppImage support
    appimage-run

    # Docker tools
    docker-compose

    # NVIDIA tools
    nvidia-docker
    nvidia-container-toolkit
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart

    # Graphics utilities
    glxinfo
    xorg.xrandr
    # Qt theming
    libsForQt5.qt5ct
    adwaita-qt
    python311
    vegeta  # HTTP load testing tool
    nmap    # Network scanning tool
    
    # Multimedia tools
    ffmpeg   # Video/audio processing tool
    portaudio   # Cross-platform audio I/O library
    stt      # Mozilla's Speech-to-Text engine
    openai-whisper  # OpenAI's speech recognition model
    
    # Development tools
    gcc      # GNU Compiler Collection
    pkg-config  # Helper tool for compiling applications and libraries
    devbox   # Tool for creating isolated development environments
    
    # Security tools
    ffuf     # Web fuzzer tool
    testssl  # TLS/SSL testing tool
  ];

  # Disable Redshift service to avoid conflicts
  services.redshift.enable = false;

  # Enable FUSE for AppImage support
  boot.supportedFilesystems = [ "fuse" ];
  boot.kernelModules = [ "fuse" ];

  # Enable NVIDIA support for Docker (using the recommended approach)
  hardware.nvidia-container-toolkit.enable = true;
  # Deprecated: virtualisation.docker.enableNvidia = true;

  # Enable home-manager with backup support
  home-manager = {
    backupFileExtension = "backup";
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

  # Configure k3s container runtime (containerd) to treat the shared registry as insecure
  environment.etc."rancher/k3s/registries.yaml".text = ''
    mirrors:
      "local-registry-service.kube-system.svc.cluster.local:5000":
        endpoint:
          - "http://local-registry-service.kube-system.svc.cluster.local:5000"
  ''; # Semicolon separating this from the next attribute

  # Set system state version
  system.stateVersion = "24.11"; # NO semicolon after the last attribute
}
