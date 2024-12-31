{ config, lib, ... }:

with lib;

let
  cfg = config.sshKeys;

  # Helper function to create age secret for a user's SSH keys
  mkUserKeySecret = username: {
    name = "ssh-keys-${username}";
    file = toString ./. + "/../secrets/ssh/authorized-keys/${username}.age";  # Path relative to flake root
    owner = username;
    group = if username == "root" then "root" else "users";
    mode = "0400";
  };
in {
  options.sshKeys = {
    enable = mkEnableOption "SSH key management";

    users = mkOption {
      type = types.listOf types.str;
      default = [ "root" "user" ];
      description = "List of users to manage SSH keys for";
    };
  };

  config = mkIf cfg.enable {
    # Create age secrets for each user
    age.secrets = listToAttrs (map
      (username: nameValuePair "ssh-keys-${username}" (mkUserKeySecret username))
      cfg.users
    );

    # Apply keys to users
    environment.etc = listToAttrs (map
      (username: nameValuePair "ssh/authorized_keys.d/${username}" {
        source = config.age.secrets."ssh-keys-${username}".path;
        mode = "0444";
      })
      cfg.users
    );

    # Ensure the authorized_keys directory exists
    system.activationScripts.sshKeyDirs = ''
      mkdir -p /etc/ssh/authorized_keys.d
      chmod 755 /etc/ssh/authorized_keys.d
    '';
  };
}
