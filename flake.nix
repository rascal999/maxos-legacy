{
  description = "NixOS configuration with desktop and server variants";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nur, sops-nix, ... }@inputs: 
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    
    # Import host configuration helpers
    hostConfig = import ./lib/host-config.nix { inherit nixpkgs home-manager nur sops-nix self; };
  in {
    nixosModules = {
      # Core modules
      security = import ./modules/security/default.nix;
      scripts = import ./modules/scripts/default.nix;
      timezone = import ./modules/timezone.nix;
      user = import ./modules/core/user.nix;
      secrets = import ./modules/core/secrets.nix;
      
      # Tool bundles
      developmentBundle = import ./modules/tool-bundles/development.nix;
      securityBundle = import ./modules/tool-bundles/security.nix;
      desktopBundle = import ./modules/tool-bundles/desktop.nix;
      serverBundle = import ./modules/tool-bundles/server.nix;
      
      # Individual tools (selected tools for external use)
      docker = import ./modules/tools/docker.nix;
      restic = import ./modules/tools/restic.nix;
      zsh = import ./modules/tools/zsh.nix;
      vscode = import ./modules/tools/vscode.nix;
    };

    nixosConfigurations = {
      test = hostConfig.mkMaxOSHost {
        hostname = "test";
        hostPath = ./hosts/test/default.nix;
      };
      
      G16 = hostConfig.mkMaxOSHostWithHome {
        hostname = "G16";
        hostPath = ./hosts/G16/default.nix;
        homeConfigPath = ./hosts/G16/home.nix;
      };
      
      desktop-test-vm = hostConfig.mkMaxOSHostWithHome {
        hostname = "desktop-test-vm";
        hostPath = ./hosts/desktop-test-vm/default.nix;
        homeConfigPath = ./hosts/desktop-test-vm/home.nix;
      };
      
      rig = hostConfig.mkMaxOSHostWithHome {
        hostname = "rig";
        hostPath = ./hosts/rig/default.nix;
        homeConfigPath = ./hosts/rig/home.nix;
      };
    };
  };
}
