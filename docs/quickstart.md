# Quickstart

Test the system immediately with a desktop VM:
```bash
# Build and run desktop test VM
nixos-rebuild build-vm --flake .#desktop-test
./result/bin/run-nixos-vm

# Login credentials:
# Username: user
# Password: nixos
```

The VM comes with:
- i3 desktop environment
- Development tools (Python, Node.js)
- Common utilities
- Dark theme and modern fonts

Want to customize? Check out:
- [Default User Template](../templates/user.nix) - Default configuration with comments
- [Example User Configuration](../users/docs/example.nix) - Complete example with all options

Then override what you need:
```nix
# hosts/desktops/your-machine/default.nix
{
  userConfig.desktop.environment = "gnome";  # Just switch to GNOME
}
