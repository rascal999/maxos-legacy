{
  description = "NixOS configuration with desktop and server variants";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nur, ... }@inputs: 
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosModules = {
      security = import ./modules/security/default.nix;
    };

    nixosConfigurations = {
      G16 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              nur.overlays.default
              (final: prev: {
                linuxPackages_latest = pkgs-unstable.linuxPackages_latest;
              })
            ];
          }
          ./hosts/G16/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.user = { pkgs, ... }: {
                imports = [
                  ./hosts/G16/home.nix
                ];
                home.stateVersion = "24.11";
              };
            };
          }
        ];
      };
      desktop-test-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              nur.overlays.default
            ];
          }
          ./hosts/desktop-test-vm/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.user = { pkgs, ... }: {
                imports = [
                  ./hosts/desktop-test-vm/home.nix
                ];
                home.stateVersion = "24.11";
              };
            };
          }
        ];
      };
      rig = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              nur.overlays.default
              (final: prev: {
                linuxPackages_latest = pkgs-unstable.linuxPackages_latest;
              })
            ];
          }
          ./hosts/rig/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.user = { pkgs, ... }: {
                imports = [
                  ./hosts/rig/home.nix
                ];
                home.stateVersion = "24.11";
              };
            };
          }
        ];
      };
    };
  };
}
