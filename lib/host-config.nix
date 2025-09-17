{ nixpkgs, home-manager, nur, sops-nix, self }:

let
  lib = nixpkgs.lib;
  
  # Common configuration shared by all hosts
  commonModules = [
    {
      nixpkgs.config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
      nixpkgs.overlays = [
        nur.overlays.default
      ];
    }
    ../modules/system-layered.nix   # Import layered system-level MaxOS modules
    self.nixosModules.scripts
    self.nixosModules.timezone
    sops-nix.nixosModules.sops
    home-manager.nixosModules.home-manager
  ];
  
  # Common home-manager configuration
  commonHomeManagerConfig = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = lib.mkDefault "backup";
  };

in rec {
  # Create a NixOS configuration with standard MaxOS settings
  mkMaxOSHost = { hostname, hostPath, userName ? "user", homeConfigPath ? null }:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = commonModules ++ [
        hostPath
        {
          home-manager = commonHomeManagerConfig // {
            users.${userName} = { pkgs, osConfig, ... }: {
              imports = [
                ../modules/home-layered.nix  # Import layered home-manager modules
              ] ++ lib.optionals (homeConfigPath != null) [ homeConfigPath ];
              home.stateVersion = "25.05";
              
              # Make system user config available in home-manager context
              _module.args.osConfig = osConfig;
            };
          };
          # Set the hostname and user configuration
          networking.hostName = hostname;
          maxos.user.name = userName;
        }
      ];
    };
    
  # Variant for hosts with custom home configuration
  mkMaxOSHostWithHome = { hostname, hostPath, homeConfigPath, userName ? "user" }:
    mkMaxOSHost {
      inherit hostname hostPath userName;
      homeConfigPath = homeConfigPath;
    };
}