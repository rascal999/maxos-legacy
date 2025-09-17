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
      user = import ./modules/01-core/system/user.nix;
      secrets = import ./modules/01-core/system/secrets.nix;
      
      # Tool bundles
      developmentBundle = import ./modules/05-bundles/tool-bundles/development.nix;
      securityBundle = import ./modules/05-bundles/tool-bundles/security.nix;
      desktopBundle = import ./modules/05-bundles/tool-bundles/desktop.nix;
      serverBundle = import ./modules/05-bundles/tool-bundles/server.nix;
      
      # Individual tools (selected tools for external use)
      docker = import ./modules/04-applications/system/tools/containers/docker/docker.nix;
      restic = import ./modules/04-applications/system/tools/data/backup/restic.nix;
      zsh = import ./modules/04-applications/system/tools/terminal/shells/zsh.nix;
      vscode = import ./modules/04-applications/system/tools/development/editors/vscode.nix;
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
      
      rig-minimal = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/rig-minimal/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
      };
    };
  };
}
