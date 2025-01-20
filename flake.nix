{
  description = "NixOS configuration with desktop and server variants";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, ... }@inputs: 
  let
    lib = nixpkgs.lib;
  in {
    nixosModules = {
      security = import ./modules/security/default.nix;
    };

    nixosConfigurations = {
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
                  ./hosts/desktop/home.nix
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
