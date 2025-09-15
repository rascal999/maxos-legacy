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
      scripts = import ./modules/scripts/default.nix;
      timezone = import ./modules/timezone.nix;
    };

    nixosConfigurations = {
      G16 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.config = {
              allowUnfree = true;
              android_sdk.accept_license = true; # Accept Android SDK license
            };
            nixpkgs.overlays = [
              nur.overlays.default
            ];
          }
          self.nixosModules.scripts
          self.nixosModules.timezone
          ./hosts/G16/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = lib.mkDefault "backup";
              users.user = { pkgs, ... }: {
                imports = [
                  ./hosts/G16/home.nix
                ];
                home.stateVersion = "25.05";
              };
            };
          }
        ];
      };
      desktop-test-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.config = {
              allowUnfree = true;
              android_sdk.accept_license = true; # Accept Android SDK license
            };
            nixpkgs.overlays = [
              nur.overlays.default
            ];
          }
          self.nixosModules.scripts
          self.nixosModules.timezone
          ./hosts/desktop-test-vm/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = lib.mkDefault "backup";
              users.user = { pkgs, ... }: {
                imports = [
                  ./hosts/desktop-test-vm/home.nix
                ];
                home.stateVersion = "25.05";
              };
            };
          }
        ];
      };
      rig = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          {
            nixpkgs.config = {
              allowUnfree = true;
              android_sdk.accept_license = true; # Accept Android SDK license
            };
            nixpkgs.overlays = [
              nur.overlays.default
            ];
          }
          self.nixosModules.scripts
          self.nixosModules.timezone
          ./hosts/rig/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = lib.mkDefault "backup";
              users.user = { pkgs, ... }: {
                imports = [
                  ./hosts/rig/home.nix
                ];
                home.stateVersion = "25.05";
              };
            };
          }
        ];
      };
    };
  };
}
