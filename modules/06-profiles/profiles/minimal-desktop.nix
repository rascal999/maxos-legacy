{ config, lib, ... }:

# Minimal desktop profile for lightweight systems and basic productivity

with lib;

{
  imports = [
    # Minimal bundle set
    ../tool-bundles/terminal.nix
    ../tool-bundles/desktop.nix
  ];

  # Enable bundles with minimal profiles
  modules.toolBundles = {
    terminal = {
      enable = mkDefault true;
      profile = mkDefault "minimal";
      enableEnhancedShell = mkDefault false;
      enableMultiplexer = mkDefault false;
      enableDevelopmentEnv = mkDefault false;
    };
    
    desktop = {
      enable = mkDefault true;
      enableAll = mkDefault false;
      browsers = mkDefault true;
      terminal = mkDefault true;
      utilities = mkDefault false;
      productivity = mkDefault false;
      multimedia = mkDefault false;
      remoteAccess = mkDefault false;
    };
  };

  # Minimal tool set
  maxos.tools = {
    # Essential browser only
    chromium.enable = mkDefault true;
    
    # Basic system input
    keyd.enable = mkDefault true;
  };

  # User configuration
  maxos.user = {
    workspaceDirectory = mkDefault "/home/user";
  };

  # Lightweight system configuration
  services.xserver = {
    enable = mkDefault true;
    desktopManager.xterm.enable = mkDefault false;
    displayManager.lightdm.enable = mkDefault true;
  };
}