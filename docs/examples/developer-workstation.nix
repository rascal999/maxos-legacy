# Example: Developer workstation with full-stack development profile
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the full-stack developer profile
  maxos.profiles.fullStackDeveloper = true;
  
  # Customize user information
  maxos.user = {
    name = "developer";
    homeDirectory = "/home/developer";
    fullName = "John Developer";
    email = "john@mycompany.com";
    monorepoDirectory = "/home/developer/code/monorepo";
    workspaceDirectory = "/home/developer/projects";
  };
  
  # Profile customizations (optional)
  maxos.profiles.customizations.fullStackDeveloper = {
    tools = {
      # Override default Git settings
      git.defaultBranch = "develop";
      git.extraConfig = {
        pull.rebase = false;
        core.editor = "code --wait";
      };
      
      # Customize Docker settings
      docker.liveRestore = true;
      docker.enableExperimental = true;
      
      # Add specific VSCode extensions
      vscode.extensions = [
        "ms-python.python"
        "bradlc.vscode-tailwindcss"
        "ms-vscode.vscode-typescript-next"
      ];
    };
    
    # Additional tools not in the default profile
    modules.tools = {
      # Add specific language support
      python.enable = true;
      golang.enable = true;
      
      # Add database tools
      postgresql.enable = true;
      
      # Add monitoring
      grafana.enable = true;
    };
  };

  # Enable secrets management
  maxos.secrets.enable = true;
  
  # System configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "dev-workstation";
  networking.networkmanager.enable = true;
  
  # Filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/your-root-uuid";
    fsType = "ext4";
  };
  
  system.stateVersion = "25.05";
}