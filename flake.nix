{
  description = "NixOps deployment for desktop and VMs with Home Manager integration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, deploy-rs, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      lib = nixpkgs.lib;
      
      # Helper to make machine configurations
      mkHost = name: { system ? "x86_64-linux", ... } @ args:
        lib.nixosSystem {
          inherit system;
          modules = [
            # Base configuration
            ./hosts/common
            # Machine-specific configuration
            ./hosts/${name}
            # Home-manager module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                inherit (self) outputs;
              };
            }
            # Secrets management
            agenix.nixosModules.age
          ];
          specialArgs = {
            inherit inputs;
            inherit (self) outputs;
          };
        };
    in {
      nixosConfigurations = {
        # Desktop configuration
        desktop = mkHost "desktop" {
          system = "x86_64-linux";
        };
        
        # Example VM configuration
        vm-test = mkHost "vms/test" {
          system = "x86_64-linux";
        };
      };

      # Deployment configuration using deploy-rs
      deploy.nodes = {
        desktop = {
          hostname = "localhost";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.desktop;
          };
        };
        
        vm-test = {
          hostname = "localhost";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.vm-test;
          };
        };
      };

      # System checks
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      
      # Overlay for custom packages
      overlays = import ./overlays;
      
      # Custom packages
      packages.${system} = import ./packages { inherit pkgs; };
      
      # Custom NixOS modules
      nixosModules = import ./modules;
      
      # Custom Home Manager modules
      homeManagerModules = import ./home/modules;
    };
}
