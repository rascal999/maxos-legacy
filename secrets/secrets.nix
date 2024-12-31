# This file defines how secrets are encrypted and who can decrypt them
let
  # Define trusted user keys that can decrypt secrets
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."; # Replace with your public key
  
  # Define trusted system keys
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."; # Replace with desktop's public key
  vm-test = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."; # Replace with VM's public key
  
  # Define groups of keys for different access levels
  allSystems = [ desktop vm-test ];
  administrators = [ user ];
in
{
  # SSH authorized keys
  "ssh/authorized-keys/root.age".publicKeys = allSystems ++ administrators;
  "ssh/authorized-keys/user.age".publicKeys = allSystems ++ administrators;

  # System secrets
  "wireguard-private-key.age".publicKeys = allSystems ++ administrators;
  "user-password.age".publicKeys = allSystems ++ administrators;
  
  # User-specific secrets
  "ssh/github.age".publicKeys = [ user desktop ];
  "ssh/gitlab.age".publicKeys = [ user desktop ];
  "gpg/private-key.age".publicKeys = [ user desktop ];
  
  # Service secrets
  "services/restic-password.age".publicKeys = allSystems;
  "services/backup-credentials.age".publicKeys = allSystems;
  
  # Development secrets
  "development/env-development.age".publicKeys = [ user desktop vm-test ];
  "development/env-production.age".publicKeys = [ user desktop ];
}
