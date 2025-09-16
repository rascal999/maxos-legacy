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
    ../../modules/tools/llm/default.nix  # Import LLM modules (fabric-ai, open-webui, and ollama)
    ../../modules/tools/tor-browser  # Import Tor Browser module
    # Import tool bundles
    ../../modules/tool-bundles/desktop.nix
    ../../modules/tool-bundles/development.nix
    ../../modules/tool-bundles/security.nix
    ../../modules/tool-bundles/server.nix
  ];

  # Configure user settings
  maxos.user = {
    name = "user";
    homeDirectory = "/home/user";
    gitDirectory = "/home/user/git";
    monorepoDirectory = "/home/user/git/github/monorepo";
    secretsDirectory = "/home/user/git/github/monorepo/secrets";
    workspaceDirectory = "/home/user/monorepo/tools/goose/workspace";
  };

  # Enable secrets management (disabled - secrets file missing)
  maxos.secrets.enable = false;

  # Enable tool bundles for organized configuration (temporarily disabled for testing)
  modules.toolBundles = {
    desktop.enable = false;
    development.enable = false; 
    security.enable = false;
    server.enable = false;
  };

  # Configure specific tools with custom settings (minimal set for testing)
  modules.tools = {
    # Basic tools that should work
    docker.enable = true;
    chromium.enable = true;
    keepassxc.enable = true;
    
    # Configure restic (disabled - secrets not available)
    restic = {
      enable = false;
      hostSubdir = "G16";
      useSopsSecrets = false;
    };
  };

  modules.tools.ollama.enable = false;
  # Enable Open WebUI
  modules.tools.open-webui.enable = false;

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

  # Enable PAM service for i3lock
  security.pam.services.i3lock.enable = true;

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
    colmena # NixOS deployment tool
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
    configs:
      "registry.localhost":
        tls:
          insecure_skip_verify: true
  '';

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
