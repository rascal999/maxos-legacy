# MaxOS Nix Flake Deployment

A Nix flake deployment configuration for managing both physical machines and virtual machines, with a focus on desktop configuration and Home Manager integration. Uses deploy-rs for deployment management.

## Features

- Modular system configuration with Nix Flakes
- Home Manager integration for user environment management
- Secure secrets management with agenix
- VM-based testing environment
- Comprehensive desktop environment setup with Sway
- Advanced audio configuration with PipeWire
- Robust networking setup with security features

## Directory Structure

```
.
├── flake.nix                 # Main entry point and configuration
├── hosts/                    # Machine-specific configurations
│   ├── common/              # Shared configurations
│   ├── desktop/             # Desktop-specific config
│   └── vms/                 # VM configurations
├── home/                    # Home Manager configurations
│   ├── common/             # Shared home configurations
│   └── profiles/           # Different user profiles
├── secrets/                # Encrypted secrets (handled by agenix)
├── scripts/               # Utility scripts
└── lib/                   # Helper functions
```

## Getting Started

1. Install required dependencies:
   ```bash
   # Enable flakes
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

   # Install tools
   nix profile install github:serokell/deploy-rs
   nix profile install github:ryantm/agenix
   ```

2. Clone the repository:
   ```bash
   git clone <repository-url> maxos
   cd maxos
   ```

3. Generate SSH keys for secrets management:
   ```bash
   ./scripts/manage-secrets.sh rotate
   ```

4. Create initial secrets:
   ```bash
   ./scripts/manage-secrets.sh create user-password
   ./scripts/manage-secrets.sh create wireguard-private-key
   ```

5. Deploy to VM for testing:
   ```bash
   deploy .#vm-test
   ```

6. Once tested, deploy to physical machine:
   ```bash
   deploy .#desktop
   ```

## VM Testing

Test changes safely in a VM before deploying to physical hardware:

1. Build and run the test VM:
   ```bash
   # Build the VM
   nix build .#nixosConfigurations.vm-test.config.system.build.vm
   # Run the VM
   ./result/bin/run-nixos-vm
   # Or deploy directly to VM
   deploy .#vm-test
   ```

2. Test secrets decryption:
   ```bash
   ./scripts/manage-secrets.sh test
   ```

## Secrets Management

Secrets are managed using [agenix](https://github.com/ryantm/agenix) and the included management script:

- Create new secrets: `./scripts/manage-secrets.sh create SECRET_NAME`
- Edit existing secrets: `./scripts/manage-secrets.sh edit SECRET_NAME`
- Rotate encryption keys: `./scripts/manage-secrets.sh rotate`
- List all secrets: `./scripts/manage-secrets.sh list`

## Home Manager Integration

User environments are managed through Home Manager:

1. Base configuration in `home/common/`
2. Profile-specific configurations in `home/profiles/`
3. Machine-specific overrides in respective host configurations

## Best Practices

1. **Testing Changes**:
   - Always test changes in VM first
   - Use `nix flake check` before deployment
   - Keep VM configuration as close to physical hardware as possible

2. **Secrets Management**:
   - Never commit unencrypted secrets
   - Regularly rotate encryption keys
   - Use separate keys for different security levels
   - Backup keys securely

3. **Configuration Management**:
   - Keep configurations modular
   - Use common configurations where possible
   - Document machine-specific overrides
   - Version control all changes

4. **Updates and Maintenance**:
   - Regularly update nixpkgs
   - Test updates in VM before deploying
   - Keep deployment generations for rollback
   - Monitor system health and logs

## Customization

1. **Adding New Machines**:
   - Copy and modify existing configurations
   - Generate new encryption keys
   - Add to secrets.nix
   - Test in VM before deployment

2. **Modifying User Environment**:
   - Edit relevant files in `home/`
   - Test changes with Home Manager
   - Deploy to VM for verification

3. **Adding New Services**:
   - Create service configuration
   - Add to relevant host configurations
   - Test thoroughly in VM

## Troubleshooting

1. **Deployment Issues**:
   - Check system logs: `journalctl -xeu deploy-rs`
   - Verify network connectivity
   - Check secret accessibility
   - Try deployment with `--debug` flag

2. **Secret Management**:
   - Verify key permissions
   - Check agenix logs
   - Ensure keys are properly distributed

3. **VM Testing**:
   - Verify VM resources
   - Check network configuration
   - Compare with physical hardware

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in VM
5. Submit a pull request

## License

MIT License - See LICENSE file for details
