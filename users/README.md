# User Configurations

This directory contains user-specific configurations for MaxOS. Each file in this directory represents a user's personal settings and preferences.

## Creating a New User Configuration

1. Copy the example configuration:
```bash
cp ./docs/example-user.nix your-username.nix
```

2. Edit the configuration file with your settings:
- Set your identity (username, full name, email)
- Configure authentication (password, SSH keys)
- Set keyboard preferences
- Choose your desktop environment
- Add development tools
- Configure security settings

See `./docs/example-user.nix` for a complete example with common settings, or use `user.nix` as a minimal template.

## Using Your Configuration

Import your configuration file in your machine's configuration:

```nix
# hosts/your-machine/default.nix
{
  imports = [
    ../../profiles/desktop.nix  # Or other relevant profile
    ./hardware-configuration.nix
    ../../users/your-username.nix  # Your user configuration
  ];
  
  networking.hostName = "your-machine";
}
```

## Security Note

- Do not commit files containing sensitive information (passwords, private keys)
- Use agenix for secrets management
- Keep SSH public keys in the configuration, but never private keys
