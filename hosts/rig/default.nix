{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ./boot.nix
    ./nvidia.nix
    ./audio.nix
    ./monitors.nix
    ./keyd.nix # Import keyd configuration
    # Note: Individual tool imports removed - now handled by layered system
    # Tools are configured via modules.tools.* options below
  ];

  # Hardware profile for desktop rig (only wireless/bluetooth, graphics and audio handled by specific configs)
  maxos.hardware.desktop = {
    enable = true;
    graphics.enable = false;  # Handled by nvidia.nix
    audio.enable = false;     # Handled by audio.nix
    wireless = {
      enable = true;
      bluetooth = true;
    };
  };

  # Use comprehensive workstation profile
  maxos.profiles.comprehensiveWorkstation = {
    enable = true;
    profile = "full";  # full profile includes all tools and capabilities
    enableDevelopment = true;
    enableGaming = true;
    enableSecurity = true;
    enableMultimedia = true;
    enableInfrastructure = true;
  };
  
  # Override tool configurations to disable SOPS secrets
  maxos.tools.restic.useSopsSecrets = false;
  
  # Disable blocky to fix WireGuard DNS resolution
  maxos.tools.blocky.enable = lib.mkForce false;
  
  # Enable screenshot tools (maim and scrot) for screenshot script
  maxos.tools.screenshot-tools.enable = true;

  # Enable asciinema terminal recorder and agg
  maxos.tools.asciinema.enable = true;
  
  # Enable pandoc for document conversion
  maxos.tools.pandoc.enable = true;
  maxos.tools.pandoc.includeExtensions = true;
  
  # Enable just command runner
  maxos.tools.just.enable = true;
  
  # Enable bun JavaScript runtime
  maxos.tools.bun.enable = true;

  # Enable Android Studio
  maxos.tools.android-studio.enable = true;

  # Enable Python 3
  #maxos.tools.python3.enable = true;
  
  # Enable Ollama AI language model server (uses CUDA by default)
  maxos.tools.ollama.enable = true;
  
  # Enable OpenAI Codex CLI tool
  maxos.tools.codex.enable = true;

  # Enable Wireshark for network analysis
  maxos.tools.wireshark.enable = true;
  
  # Enable OBS Studio for screen recording and streaming
  maxos.tools.obs = {
    enable = true;
    enablePlugins = true;
    enableVirtualCamera = true;
  };
  
  # Enable Kubernetes tooling
  maxos.tools.helmfile.enable = true;
  maxos.tools.aws-cli.enable = true;
  maxos.tools.google-cloud-sdk.enable = true;
  maxos.tools.stripe-cli.enable = true;
  maxos.tools.k3s = {
    enable = true;
    role = "server";
    traefik = {
      enable = false;  # Disabled in favor of standalone Traefik with MetalLB
      hostPort = false;
      staticIP = "";  # Cleared since traefik is disabled
    };
    extraFlags = [
      # servicelb is automatically disabled when staticIP is configured
      # disable-cloud-controller is automatically added for server role
    ];
  };
  
  # Enable iSCSI storage support
  maxos.tools.open-iscsi.enable = true;
  
  # Enable OpenVPN client
  maxos.tools.openvpn.enable = true;

  # Enable SSHFS for remote filesystem mounting
  maxos.tools.sshfs.enable = true;
  
  # Enable TeamViewer for remote access
  maxos.tools.teamviewer.enable = true;
  
  # Enable Firecracker microVM virtualization
  maxos.tools.firecracker = {
    enable = true;
    includeFirectl = true;
  };
  
  # Enable Redis for development and caching
  maxos.tools.redis = {
    enable = false;
    maxMemory = "1gb";
    maxMemoryPolicy = "allkeys-lru";
    appendOnly = true;
    logLevel = "notice";
    databases = 16;
    redisInsight = {
      enable = false;
      port = 8001;
      host = "127.0.0.1";
    };
  };
  
  # Enable MongoDB CE for document database development
  maxos.tools.mongodb-ce = {
    enable = false;
    port = 27017;
    bind = "127.0.0.1";
    enableAuth = false;  # Disabled for local development
    storageEngine = "wiredTiger";
    journaling = true;
    logLevel = "normal";
    cacheSizeGB = 2;  # 2GB cache for desktop
    databases = [ "development" "testing" ];
  };
  
  # Explicitly disable AI tools that might cause build issues
  maxos.tools.open-webui.enable = lib.mkForce false;

  # Enable Knot DNS for authoritative DNS testing
  maxos.tools.knot-dns.enable = true;

  # Enable FileZilla FTP client
  maxos.tools.filezilla.enable = true;

  # Enable Prowlarr, Sonarr and qBittorrent
  maxos.services.prowlarr.enable = true;
  maxos.services.sonarr.enable = true;
  maxos.services.qbittorrent.enable = true;

  # Rocket.Chat service disabled (module import commented out)

  # Disable system-wide Firefox
  programs.firefox.enable = false;

  # Enable Solaar/Logitech device support
  hardware.logitech.wireless.enable = true;

  # Enable zsh
  programs.zsh.enable = true;

  # Enable security module with default settings
  security = {
    enable = true;
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKy1zrCNG5lCnBXaZwgyUgt5Yd01j695xBSgdoJXKrY1 user@nixos"  # G16's key
    ];
  };

  # PAM service for i3lock (not available in 24.11)
  # security.pam.services.i3lock.enable = true;

  # Set hostname
  networking.hostName = "rig";
  
  # Enable centralized font management
  maxos.fonts.enable = true;
  
  # Disable secrets management for now
  maxos.secrets = {
    enable = false;
    age.generateKey = false;
    # defaultSopsFile = "${config.maxos.user.secretsDirectory}/hosts/rig/secrets.yaml";
  };
  
  # User configuration
  maxos.user = {
    name = "user";
    homeDirectory = "/home/user";
    gitDirectory = "/home/user/git";
    monorepoDirectory = "/home/user/git/github/monorepo";
    secretsDirectory = "/home/user/git/github/monorepo/secrets";
    workspaceDirectory = "/home/user/projects";
  };
  
  # Add hosts entries
  networking.hosts = {
    "127.0.0.2" = [ "management-api.fisheye.local" "auth-service.fisheye.local" ];
    "10.129.4.188" = [ "gavel.htb" ];
  };
  
  # Disable automatic /etc/hosts generation
  environment.etc.hosts.enable = false;

  # Udev rules for PTT script device access
  services.udev.extraRules = ''
    # Grant user 'user' read/write access to the specific mouse event device for PTT script
    KERNEL=="event3", SUBSYSTEM=="input", OWNER="user", MODE="0660"
    
    # Grant 'input' group read/write access to uinput for PTT script to re-emit events.
    # User 'user' should be part of the 'input' group.
    KERNEL=="uinput", SUBSYSTEM=="misc", GROUP="input", MODE="0660", TAG+="uaccess"
    # Logitech USB Receiver hidraw access
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", MODE="0660", GROUP="plugdev"
  '';

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
  services.displayManager = {
    defaultSession = "none+i3";
    # Enable autologin
    autoLogin = {
      enable = true;
      user = "user";
    };
  };

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
    mesa-demos
    xorg.xrandr
    edid-decode
    # Qt theming
    libsForQt5.qt5ct
    adwaita-qt
    python311
    python3Packages.pip
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
    clamav   # Antivirus scanner

    # For Python PTT script
    python3
    python3Packages.evdev
    python3Packages.python-uinput
    solaar # Logitech device management tool
    usbutils # For lsusb
    pkgs.evsieve # For advanced input event manipulation (PTT script)
    # goose-cli # Database migration tool (not available in 24.11)
    
    # Keyring support
    gnome-keyring
    kubectl # Kubernetes command-line tool
    bind # For dig command
    colmena # NixOS deployment tool
    postgresql # PostgreSQL client tools (psql, pg_dump, etc.)
  ];

  # Mount Storage Box via SSHFS
  fileSystems."/home/user/media" = {
    device = "u531385@u531385.your-storagebox.de:/";
    fsType = "fuse.sshfs";
    options = [
      "allow_other"
      "uid=1000"
      "gid=100"
      "idmap=user"
      "IdentityFile=/home/user/.ssh/id_ed25519"
      "ssh_command=${pkgs.openssh}/bin/ssh"
      "StrictHostKeyChecking=no"
      "UserKnownHostsFile=/dev/null"
      "x-systemd.automount"
      "_netdev"
      "reconnect"
      "ServerAliveInterval=15"
      "ServerAliveCountMax=3"
      "delay_connect"
    ];
  };

  # Add user to plugdev group for Logitech device access
  users.users.user.extraGroups = [ "plugdev" ];

  # Disable Redshift service to avoid conflicts
  services.redshift.enable = false;

  # Enable GNOME keyring service
  services.gnome.gnome-keyring.enable = true;

  # Enable FUSE for AppImage support
  boot.supportedFilesystems = [ "fuse" ];
  boot.kernelModules = [ "fuse" ];

  # Enable NVIDIA support for Docker (using the recommended approach)
  hardware.nvidia-container-toolkit.enable = true;

  # Enable home-manager with backup support
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    users.user = { pkgs, ... }: {
      imports = [
        ./home.nix
        # Note: i3, alacritty and zsh now imported via layered home system
      ];

      # GTK configuration
      gtk = {
        enable = true;
        theme = {
          name = lib.mkForce "Adwaita-dark";
          package = lib.mkForce pkgs.adwaita-icon-theme;
        };
        iconTheme = {
          name = lib.mkForce "Adwaita";
          package = lib.mkForce pkgs.adwaita-icon-theme;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = lib.mkForce true;
        };
        gtk4.extraConfig = {
          gtk-application-prefer-dark-theme = lib.mkForce true;
        };
      };

      # Qt configuration
      qt = {
        enable = true;
        platformTheme.name = lib.mkForce "qtct";
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
  ''; # Semicolon separating this from the next attribute

  systemd.user.services.direct-ptt = {
    description = "Direct Push-to-Talk script using evsieve for Logitech mouse";
    after = [ "graphical-session.target" "pipewire.service" "wireplumber.service" ]; # Ensure audio services are up
    wantedBy = [ "graphical-session.target" ]; # Start when graphical session is ready

    serviceConfig = {
      Type = "simple";
      # IMPORTANT: Ensure this path is correct and the script is executable (chmod +x)
      # This assumes your monorepo is at /home/user/git/
      # A Nix-packaged script would be more robust.
      ExecStart = "${pkgs.bash}/bin/bash /home/user/git/github/monorepo/maxos/scripts/direct-push-to-talk.sh";
      Restart = "on-failure";
      RestartSec = "5s";
      # No User/Group needed as it's a user service, runs as the user enabling it.
      # Set PATH to include necessary commands for the script
      Environment = "PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.evsieve pkgs.wireplumber pkgs.gawk ]}";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set system state version
  system.stateVersion = "25.11"; # NO semicolon after the last attribute
}
