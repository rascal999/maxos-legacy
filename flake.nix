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
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      
      lib = nixpkgs.lib;
      
      # Helper function for VM configurations
      mkVM = { system ? "x86_64-linux", modules ? [], ... }: 
        lib.nixosSystem {
          inherit system;
          modules = [
            # VM base configuration
            ({ modulesPath, config, ... }: {
              imports = [
                (modulesPath + "/virtualisation/qemu-vm.nix")
              ];
              virtualisation = {
                cores = 2;
                memorySize = 4096;
                diskSize = 8192;
              };
              # Set VM-specific options
              virtualisation.vmVariant.virtualisation.graphics = false;
            })
          ] ++ modules;
          specialArgs = { inherit inputs; };
        };
    in {
      nixosConfigurations = {
        # Desktop configurations
        "desktops/hero" = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/desktops/hero
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
          specialArgs = { inherit inputs; };
        };

        "desktops/rig" = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/desktops/rig
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
          specialArgs = { inherit inputs; };
        };

        # Server configurations
        "servers/example" = lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/servers/example
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
          specialArgs = { inherit inputs; };
        };

        # Test VMs
        server-test = mkVM {
          modules = [
            ./hosts/vms/server-test
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };

        desktop-test = mkVM {
          modules = [
            ./hosts/vms/desktop-test
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };
      };

      # Deployment configuration using deploy-rs
      deploy = {
        nodes = {
          server-test = {
            hostname = "localhost";
            sshUser = "root";
            fastConnection = true;
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.server-test;
              sshOpts = [
                "-o" "StrictHostKeyChecking=no"
                "-o" "UserKnownHostsFile=/dev/null"
              ];
            };
          };

          desktop-test = {
            hostname = "localhost";
            sshUser = "root";
            fastConnection = true;
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.desktop-test;
              sshOpts = [
                "-o" "StrictHostKeyChecking=no"
                "-o" "UserKnownHostsFile=/dev/null"
              ];
            };
          };
        };
      };

      # System checks
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      # Overlays and packages will be added as needed
      overlays = {};
      packages.${system} = {};
    };
}
