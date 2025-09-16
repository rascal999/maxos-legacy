{ config, lib, pkgs, ... }:

# Hardware profile for laptop configurations

with lib;

let
  cfg = config.maxos.hardware.laptop;
in {
  options.maxos.hardware.laptop = {
    enable = mkEnableOption "Laptop hardware optimizations";
    
    powerManagement = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable laptop power management optimizations";
      };
      
      tlp = mkOption {
        type = types.bool;
        default = true;
        description = "Enable TLP for advanced power management";
      };
    };
    
    display = {
      backlight = mkOption {
        type = types.bool;
        default = true;
        description = "Enable backlight control";
      };
      
      autoSuspend = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic suspend on lid close";
      };
    };
    
    touchpad = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable touchpad support";
      };
      
      naturalScrolling = mkOption {
        type = types.bool;
        default = false;
        description = "Enable natural scrolling";
      };
    };
    
    wireless = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable wireless networking";
      };
      
      bluetooth = mkOption {
        type = types.bool;
        default = true;
        description = "Enable bluetooth support";
      };
    };
  };

  config = mkIf cfg.enable {
    # Power management
    powerManagement = mkIf cfg.powerManagement.enable {
      enable = true;
      powertop.enable = true;
    };
    
    services.tlp = mkIf cfg.powerManagement.tlp {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        START_CHARGE_THRESH_BAT0 = 20;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };

    # Display and backlight
    services.xserver.libinput = mkIf cfg.touchpad.enable {
      enable = true;
      touchpad = {
        naturalScrolling = cfg.touchpad.naturalScrolling;
        disableWhileTyping = true;
        scrollMethod = "twofinger";
        tapping = true;
      };
    };

    # Backlight control
    programs.light.enable = mkIf cfg.display.backlight true;
    
    # Add user to video group for backlight control
    users.users.${config.maxos.user.name}.extraGroups = mkIf cfg.display.backlight [ "video" ];

    # Lid switch handling
    services.logind = mkIf cfg.display.autoSuspend {
      lidSwitch = "suspend";
      extraConfig = ''
        HandleLidSwitchExternalPower=ignore
      '';
    };

    # Wireless networking
    networking.wireless.enable = mkIf cfg.wireless.enable false; # Use NetworkManager instead
    networking.networkmanager.enable = mkIf cfg.wireless.enable true;

    # Bluetooth
    hardware.bluetooth = mkIf cfg.wireless.bluetooth {
      enable = true;
      powerOnBoot = true;
    };

    services.blueman.enable = mkIf cfg.wireless.bluetooth true;

    # Essential laptop packages
    environment.systemPackages = with pkgs; mkIf cfg.enable [
      acpi
      powertop
      brightnessctl
    ] ++ optionals cfg.display.backlight [
      light
      acpilight
    ] ++ optionals cfg.wireless.bluetooth [
      bluetoothctl
    ];
  };
}