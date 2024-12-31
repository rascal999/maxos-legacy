# Contributing

## Development Process

1. Create a new branch for your changes:
```bash
git checkout -b feature/your-feature-name
```

2. Test changes using the appropriate test VM:
```bash
# For desktop changes
nixos-rebuild build-vm --flake .#desktop-test
./result/bin/run-nixos-vm

# For server changes
nixos-rebuild build-vm --flake .#server-test
./result/bin/run-nixos-vm
```

3. Update documentation if adding new features:
- Add new sections to relevant documentation files
- Update examples if necessary
- Document any new configuration options

4. Ensure no sensitive data is committed:
- No hardware configurations
- No secret keys or tokens
- No personal information
- No machine-specific configurations

## Code Guidelines

### Configuration Style
- Use consistent indentation (2 spaces)
- Group related settings together
- Add comments for complex configurations
- Use descriptive names for options

### Testing
- Test all changes in VMs before committing
- Verify both desktop and server configurations if applicable
- Test with different user configurations
- Check for regressions in existing functionality

### Documentation
- Keep documentation up to date
- Document new features and changes
- Include examples for complex configurations
- Update README.md when necessary

## Pull Request Process

1. Ensure all tests pass in test VMs
2. Update documentation as needed
3. Remove any sensitive or machine-specific data
4. Submit pull request with clear description:
   - What changes were made
   - Why changes were needed
   - How to test the changes
   - Any known limitations

## Best Practices

### Security
- Never commit sensitive data
- Use agenix for secrets management
- Follow security best practices
- Document security implications

### Maintainability
- Keep configurations modular
- Use profiles for shared configurations
- Document complex setups
- Follow NixOS conventions

### Testing
- Test thoroughly in VMs
- Document test procedures
- Include example configurations
- Verify with different hardware profiles
