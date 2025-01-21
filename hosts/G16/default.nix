{ config, pkgs, lib, ... }:

{
  imports = [
    ./users.nix
    ./boot.nix
    ./nvidia.nix
    ./rog.nix
    ./audio.nix
    ./power.nix
    ./audio-power.nix
    ../../modules/security/default.nix
    ../../modules/desktop/default.nix
    ../../modules/hardware/network.nix
  ];

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
      layout = "us";
      variant = "dvorak";
      options = "terminate:ctrl_alt_bksp";
    };

    # Touchpad configuration
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = false;
        disableWhileTyping = true;
        scrollMethod = "twofinger";
        tapping = true;
        tappingDragLock = false;
      };
    };

    # Display manager configuration
    displayManager = {
      defaultSession = "none+i3";
      lightdm = {
        enable = true;
        background = "#000000";
        greeters.gtk = {
          enable = true;
          theme.name = "Adwaita-dark";
        };
      };
    };
  };

  # Add required packages
  environment.systemPackages = with pkgs; [
    # Graphics utilities
    glxinfo
    xorg.xrandr
    # Backlight utilities
    light
    acpilight
    # Qt theming
    qt5ct
    qt6ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    adwaita-qt
    adwaita-qt6
  ];

  # Configure backlight permissions and USB power management
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"

    # Comprehensive USB power management rules
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/autosuspend", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="*[Mm]ouse*", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{product}=="*[Ww]ireless*", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{manufacturer}=="*[Ll]ogitech*", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{manufacturer}=="*[Rr]azer*", ATTR{power/control}="on", ATTR{power/autosuspend}="-1"
  '';

  # Disable USB autosuspend and power saving globally
  boot.extraModprobeConfig = ''
    options usbcore autosuspend=-1
    options usbhid mousepoll=1
    options usb-storage quirks=0419:aaf5:u0419:aaf6:u
  '';

  # Additional kernel parameters for USB
  boot.kernelParams = [
    "usbcore.autosuspend=-1"
    "usbhid.mousepoll=1"
  ];

  # Add user to video group for backlight control
  users.users.user.extraGroups = [ "video" ];

  # Disable Redshift service to avoid conflicts
  services.redshift.enable = false;

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
          package = pkgs.gnome.adwaita-icon-theme;
        };
        iconTheme = {
          name = "Adwaita";
          package = pkgs.gnome.adwaita-icon-theme;
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
        platformTheme = "qt5ct";
        style = {
          name = "kvantum";
        };
      };

      # Environment variables
      home.sessionVariables = {
        GTK_THEME = "Adwaita:dark";
        QT_QPA_PLATFORMTHEME = "qt5ct";
        QT_STYLE_OVERRIDE = "kvantum";
      };

      # Configure Kvantum theme
      xdg.configFile = {
        "Kvantum/kvantum.kvconfig".text = ''
          [General]
          theme=KvAdaptaDark
        '';
        "qt5ct/qt5ct.conf".text = ''
          [Appearance]
          style=kvantum
          custom_palette=false
          standard_dialogs=default
          color_scheme_path=${pkgs.adwaita-qt}/share/qt5ct/colors/airy.conf

          [Interface]
          stylesheets=@Invalid()
          dialogbuttons_have_icons=true
          keyboard_scheme=2
          menus_have_icons=true
          show_shortcuts_in_context_menus=true
          toolbutton_style=4
          underline_shortcut=1
          wheel_scroll_lines=3

          [Fonts]
          fixed="@Variant(\0\0\0@\0\0\0\x12\0M\0o\0n\0o\0s\0p\0\x61\0\x63\0\x65@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)"
          general="@Variant(\0\0\0@\0\0\0\x12\0M\0o\0n\0o\0s\0p\0\x61\0\x63\0\x65@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)"
        '';
      };
    };
  };

  # Set system state version
  system.stateVersion = "24.11";
}
