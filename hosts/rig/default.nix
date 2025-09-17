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

  # Enable tools
  modules.tools = {
    postman.enable = true;
    npm.enable = true;
    traefik.enable = false;  # Disable standalone Traefik to use k3s built-in one
    fabric-ai.enable = true;
    git-crypt.enable = true;
    mongodb = {
      enable = false;        # Disable MongoDB for faster installation
      compass.enable = false; # Disable MongoDB Compass GUI
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
      useSopsSecrets = true; # Use SOPS for backup credentials
    };
    remmina.enable = true;  # Enable Remmina
    k3s = {
      enable = true;
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
    whatsapp-mcp = {
      enable = true;
      user = "user"; # Use the main user account instead of a system user
      group = "users"; # Use the users group
      dataDir = "/home/user/git/github/whatsapp-mcp/data"; # Store data in the git repo
    };
    tor-browser.enable = true;  # Enable Tor Browser
    gpsbabel.enable = true;  # Enable GPSBabel
    linuxquota = {
      enable = true;
      enableUserQuotas = true;
      enableGroupQuotas = true;
    };
    sshfs.enable = true;  # Enable SSHFS
    forgejo = {
      enable = true;
      port = 3000;
      domain = "172.17.0.1";
      rootUrl = "http://172.17.0.1:3000/";
      actions.enable = true;
      lfs.enable = true;
    };
    forgejo-runner = {
      enable = true;  # Enabled - token file has been created
      enableDocker = true;
      enableIPv6 = false;
      instances.rig-runner = {
        enable = true;  # Enabled - token file has been created
        name = "rig-runner";
        url = "http://172.17.0.1:3000/";
        tokenFile = "/var/lib/forgejo-runner/rig-runner-token";  # Token file created
        labels = [
          "docker:docker://python:3.11-bookworm"
          "ubuntu-latest:docker://ubuntu:latest"
          "nixos-latest:docker://nixos/nix"
        ];
        settings = {
          container = {
            network = "host";  # Use host networking to access 172.17.0.1:3000
          };
        };
      };
     };
    faas-cli.enable = true;  # Enable faas-cli
    kind.enable = false;  # Disable kind (Kubernetes in Docker)
    skaffold.enable = true;  # Enable Skaffold
    qdirstat.enable = true;  # Enable QDirStat
    mosh.enable = true;  # Enable Mosh (mobile shell)
    argocd.enable = true;  # Enable ArgoCD CLI
    brave.enable = true;  # Enable Brave browser
   };
  modules.tools.trivy.enable = true; # Enable Trivy
  modules.tools.semgrep.enable = true; # Enable Semgrep
  modules.tools.ollama.enable = false;
  modules.tools.syft.enable = true; # Enable Syft
  modules.tools.grype.enable = true; # Enable Grype

  # Enable Open WebUI
  modules.tools.open-webui.enable = false;


  # Enable SimpleScreenRecorder
  modules.tools.simplescreenrecorder.enable = true;

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
  
  # Enable secrets management
  maxos.secrets = {
    enable = true;
    age.generateKey = true;
    defaultSopsFile = "${config.maxos.user.secretsDirectory}/hosts/rig/secrets.yaml";
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
    "127.0.0.1" = [ "management-api.fisheye.local" "auth-service.fisheye.local" ];
  };

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
    edid-decode
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
  ];

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
        ../../modules/tools/i3/desktop.nix
        # Note: alacritty and zsh now imported via layered home system
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
  system.stateVersion = "25.05"; # NO semicolon after the last attribute
}
