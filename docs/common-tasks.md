# Common Tasks

## System Updates

### Update System
```bash
# Update flake inputs
nix flake update

# Update and switch to new configuration
nixos-rebuild switch --flake .#desktops/hero
```

### Clean Up
```bash
# Remove old generations
sudo nix-collect-garbage -d

# Remove specific generation
sudo nix-env --delete-generations old
```

### Debug
```bash
# Show system closure size
nix path-info -Sh /run/current-system

# Show dependency graph
nix-store -q --graph /run/current-system | dot -Tsvg > system-graph.svg
```

## Access Management

### SSH Keys
To add a new SSH key:
1. Add the public key to `secrets/ssh/authorized-keys/`
2. Update the key in agenix:
```bash
agenix -e secrets/ssh/authorized-keys/user.age
```

### Secrets
To manage secrets:
```bash
# Edit existing secret
agenix -e secrets/secrets.age

# Add new secret
scripts/manage-secrets.sh add my-secret
```

## Hardware Management

### Generate Hardware Config
For new physical machines:
```bash
# Generate hardware config
nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

### Test in VM
Before deploying to physical hardware:
```bash
# Test configuration in VM
nixos-rebuild build-vm --flake .#desktop-test
./result/bin/run-nixos-vm
```

## Maintenance

### Backup
Regular maintenance tasks:
1. Backup hardware configurations
2. Document manual changes
3. Test configurations in VMs
4. Clean old generations

### Troubleshooting
Common debugging steps:
1. Check system logs
2. Verify configuration syntax
3. Test in VM
4. Review hardware config
