{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.firecracker;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
  userConfig = config.maxos.user;
  
in {
  options.maxos.tools.firecracker = {
    enable = mkEnableOption "Firecracker microVM virtualization";
    
    includeFirectl = mkOption {
      type = types.bool;
      default = true;
      description = "Include firectl command-line tool for managing Firecracker VMs";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = with pkgs; [
      firecracker
    ] ++ optionals cfg.includeFirectl [
      firectl
    ];

    # Enable KVM support for Firecracker
    boot.kernelModules = [ "kvm-intel" "kvm-amd" ];
    
    # Add user to kvm group for Firecracker access
    users.users.${userConfig.name}.extraGroups = [ "kvm" ];
    
    # Ensure /dev/kvm has proper permissions
    services.udev.extraRules = ''
      KERNEL=="kvm", GROUP="kvm", MODE="0660"
    '';
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Firecracker requires user module";
      }
    ];
  };
}