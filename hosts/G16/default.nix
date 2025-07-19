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
    # ../../modules/tools/qemu.nix  # Import QEMU module
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
    ../../modules/tools/openssl.nix  # Import OpenSSL module
    ../../modules/tools/steam.nix  # Import Steam module
    ../../modules/tools/tor-browser  # Import Tor Browser module
    ../../modules/tools/blocky.nix  # Import Blocky module
    ../../modules/tools/trivy.nix  # Import Trivy module
    ../../modules/tools/semgrep.nix  # Import Semgrep module
    ../../modules/tools/gpsbabel.nix  # Import GPSBabel module
    ../../modules/tools/sshfs.nix  # Import SSHFS module
    ../../modules/tools/forgejo.nix  # Import Forgejo module
    ../../modules/tools/forgejo-runner.nix  # Import Forgejo runner module
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
      enable = false;
      role = "server";  # Configure as a server (control plane)
      extraFlags = [
        "--disable-cloud-controller"  # Disable cloud controller as this is a local setup
      ];
    };
    blocky.enable = true;
    openssl = {
      enable = true;
      installDevelopmentPackages = true;  # Install development packages
    };
    steam.enable = true; # Enable Steam
    tor-browser.enable = true;  # Enable Tor Browser
    gpsbabel.enable = true;  # Enable GPSBabel
    sshfs.enable = true;  # Enable SSHFS
    forgejo = {
      enable = true;
      port = 3000;
      domain = "localhost";
      rootUrl = "http://localhost:3000/";
      actions.enable = true;
      lfs.enable = true;
    };
    forgejo-runner = {
      enable = false;  # Disabled until proper registration token file is created
      enableDocker = true;
      enableIPv6 = false;
      instances.G16-runner = {
        enable = false;  # Disabled until proper registration token file is created
        name = "G16-runner";
        url = "http://localhost:3000/";  # Connect to local forgejo instance
        tokenFile = "/var/lib/forgejo-runner/G16-runner-token";  # Create this file with TOKEN=<actual-token>
        labels = [
          "docker:docker://node:20-bookworm"
          "ubuntu-latest:docker://ubuntu:latest"
          "nixos-latest:docker://nixos/nix"
          "gpu:docker://nvidia/cuda:12.0-runtime-ubuntu22.04"  # GPU support for G16
        ];
      };
    };
   };
  modules.tools.trivy.enable = true; # Enable Trivy
  modules.tools.semgrep.enable = true; # Enable Semgrep

  modules.tools.ollama.enable = true;
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
    pam.services.i3lock.enable = true;
  };

  # Set hostname
  networking.hostName = "G16";
  
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
    python3Packages.pip # Python package installer
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
    usbutils # For lsusb
    goose-cli # Database migration tool
    clamav   # Antivirus scanner
    
    # Keyring support
    gnome-keyring
    kubectl # Kubernetes command-line tool
    bind # For dig command
  ];

  # Add user to video group for backlight control and enable FUSE
  users.users.user.extraGroups = [ "video" ];

  # Enable FUSE for AppImage support
  boot.supportedFilesystems = [ "fuse" ];
  boot.kernelModules = [ "fuse" ];

  # Disable Redshift service to avoid conflicts
  services.redshift.enable = false;

  # Enable GNOME keyring service
  services.gnome.gnome-keyring.enable = true;


  # Enable NVIDIA support for Docker
  hardware.nvidia-container-toolkit.enable = true;

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set system state version
  system.stateVersion = "25.05";
}
