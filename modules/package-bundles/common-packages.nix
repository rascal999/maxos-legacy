# Common package bundles to reduce duplication
{ pkgs }:

rec {
  # Basic system utilities present in most configurations
  systemUtils = with pkgs; [
    htop
    btop
    neofetch
    unzip
    zip
    wget
    curl
    tree
    jq
    ripgrep
    fd
  ];

  # Development essentials
  devEssentials = with pkgs; [
    git
    gh
    neovim
    pwgen
  ];

  # Terminal and shell utilities  
  terminalUtils = with pkgs; [
    tmux
    fzf
    eza
    bat
    zoxide
  ];

  # Network and monitoring tools
  networkTools = with pkgs; [
    nmap
    tcpdump
    mtr
    nethogs
    iftop
    iotop
  ];

  # Fonts commonly used across systems
  commonFonts = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
    liberation_ttf
    noto-fonts
    noto-fonts-emoji
  ];

  # Media and file management
  mediaTools = with pkgs; [
    vlc
    feh
    pcmanfm
    ranger
    maim
    scrot
  ];

  # Desktop utilities
  desktopUtils = with pkgs; [
    networkmanagerapplet
    arandr
    redshift
    brightnessctl
    pasystray
    playerctl
  ];

  # Communication tools
  communication = with pkgs; [
    slack
    discord
  ];

  # Office and productivity
  productivity = with pkgs; [
    libreoffice
    gimp
  ];

  # Python development stack
  pythonDev = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    micromamba
    jupyter
    uv
  ];

  # Java development stack
  javaDev = with pkgs; [
    jdk
    maven
    gradle
  ];

  # Security and pentesting tools
  securityTools = with pkgs; [
    sqlmap
    mitmproxy
    gnupg
  ];

  # System administration
  sysAdmin = with pkgs; [
    awscli2
    pciutils
    bc
  ];

  # Container and orchestration tools
  containerTools = with pkgs; [
    docker
    docker-compose
    kubectl
    kind
    skaffold
  ];

  # Common desktop bundle (most frequently used combination)
  desktopBundle = systemUtils ++ devEssentials ++ terminalUtils ++ commonFonts ++ 
                  mediaTools ++ desktopUtils ++ communication ++ productivity;

  # Development workstation bundle  
  developmentBundle = desktopBundle ++ pythonDev ++ javaDev ++ containerTools;

  # Server administration bundle
  serverBundle = systemUtils ++ devEssentials ++ terminalUtils ++ networkTools ++ sysAdmin;

  # Security focused bundle
  securityBundle = systemUtils ++ devEssentials ++ securityTools ++ networkTools;
}