{ config, pkgs, lib, ... }:

{
  imports = [
    ../common/default.nix
  ];

  # Desktop environment configuration
  services.xserver = {
    enable = true;
    
    # Input configuration
    libinput = {
      enable = true;
      mouse.naturalScrolling = false;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        disableWhileTyping = true;
      };
    };
  };

  # Common desktop hardware configuration
  hardware = {
    # OpenGL
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Bluetooth
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # Audio
    pulseaudio.enable = false; # Using pipewire instead
  };

  # Desktop services
  services = {
    # Audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    
    # Power management
    thermald.enable = true;
    tlp.enable = true;
    
    # Automounting
    udisks2.enable = true;
    gvfs.enable = true;
    
    # Printing
    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplip ];
    };
    
    # DBus
    dbus.enable = true;
  };

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
    rofi
    dunst
    feh
    
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
    enableDefaultFonts = true;
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      fira-code
      fira-code-symbols
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
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

  # Security
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    
    # PAM
    pam = {
      services = {
        login.enableGnomeKeyring = true;
        swaylock = {};
      };
    };
  };

  # Power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  # Common desktop user configuration
  home-manager.users.user = { pkgs, ... }: {
    # Common desktop packages
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
      
      # Utilities
      flameshot
      keepassxc
    ];
  };
}
