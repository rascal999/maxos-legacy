{ config, pkgs, lib, ... }:

{
  # Common desktop packages
  environment.systemPackages = with pkgs; [
    # System utilities
    pciutils
    usbutils
    lm_sensors
    
    # Desktop utilities
    xclip
    xorg.xkill
    arandr
    pavucontrol
    
    # Common applications
    firefox
    alacritty
    rofi            # Application launcher
    dunst           # Notification daemon
    feh             # Image viewer and wallpaper setter
    i3              # Window manager
    
    # Media
    vlc
    mpv
    
    # File management
    pcmanfm
    unzip
    unrar
    p7zip
    
    # System monitoring
    htop
    gotop
    neofetch
  ];

  # Font configuration
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      fira-code
      fira-code-symbols
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    
    fontconfig = {
      defaultFonts = {
        monospace = [ "FiraCode Nerd Font" "DejaVu Sans Mono" ];
        sansSerif = [ "Noto Sans" "DejaVu Sans" ];
        serif = [ "Noto Serif" "DejaVu Serif" ];
      };
    };
  };

  # Common desktop user packages
  home-manager.users.user = { pkgs, ... }: {
    home.packages = with pkgs; [
      # Communication
      discord
      slack
      
      # Development tools
      vscode
      insomnia
      
      # Graphics
      gimp
      
      # Office
      libreoffice
      logseq
      
      # Utilities
      flameshot
      keepassxc
      
      # i3 related
      i3status-rust
      dmenu
      networkmanager_dmenu
      xlockmore
      light
      tesseract
      xclip
    ];
  };
}
