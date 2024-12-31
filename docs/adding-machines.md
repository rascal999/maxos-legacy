# Adding New Machines

## Adding a New Desktop

1. Create new directory:
```bash
mkdir -p hosts/desktops/new-desktop
```

2. Create configuration:
```nix
# hosts/desktops/new-desktop/default.nix
{
  imports = [
    ../../profiles/desktop.nix
    ./hardware-configuration.nix
  ];
  networking.hostName = "new-desktop";
  # Add machine-specific configurations
}
```

3. Add to flake.nix:
```nix
nixosConfigurations."desktops/new-desktop" = lib.nixosSystem {
  inherit system;
  modules = [
    ./hosts/desktops/new-desktop
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }
  ];
  specialArgs = { inherit inputs; };
};
```

## Adding a New Server

1. Create new directory:
```bash
mkdir -p hosts/servers/new-server
```

2. Create configuration:
```nix
# hosts/servers/new-server/default.nix
{
  imports = [
    ../../profiles/server.nix
    ./hardware-configuration.nix
  ];
  networking.hostName = "new-server";
  # Add server-specific configurations
}
```

3. Add to flake.nix similarly to desktop configuration.

## Important Notes

When importing profiles, ensure paths are relative to your configuration's location:
- For desktops: ../../profiles/desktop.nix (from hosts/desktops/[name]/)
- For servers: ../../profiles/server.nix (from hosts/servers/[name]/)
- For VMs: ../../profiles/vm.nix (from hosts/vms/[name]/)

## Hardware Configuration

For physical machines:
1. Boot from NixOS installation media
2. Mount filesystems
3. Generate hardware configuration:
```bash
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

For virtual machines:
- Use the shared VM hardware configuration:
```nix
imports = [
  ../../profiles/vm.nix
  ../../profiles/vm-hardware.nix
];
