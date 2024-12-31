# Example User Configuration
#
# This is an example of how to configure a user in MaxOS.
# Copy this file and modify it according to your needs.

{ config, pkgs, lib, ... }:

let
  username = "alice";
  fullName = "Alice Smith";
  email = "alice@example.com";
in {
  users.users.${username} = {
    isNormalUser = true;
    description = lib.mkDefault fullName;
    extraGroups = [ 
      "wheel"    # Enable sudo
      "networkmanager"
      "docker"
      "audio"
      "video"
      "input"
      "libvirtd"
    ];
    hashedPassword = null;  # Set this using mkpasswd -m sha-512 or through agenix
    # SSH keys are managed centrally through the ssh-keys module
    # See:
    # - modules/ssh-keys.nix for the implementation
    # - secrets/secrets.nix for the encrypted keys
    # - hosts/common/users.nix for enabling key management
    shell = pkgs.zsh;
  };

  home-manager.users.${username} = { pkgs, ... }: {
    home = {
      stateVersion = "23.11";
      username = username;
      homeDirectory = "/home/${username}";
      
      packages = with pkgs; [
        # Development
        python3
        nodejs
        go
        rustc
        cargo
        
        # Editors
        vscode
        neovim
        
        # Browsers
        firefox
        chromium
        
        # Communication
        slack
        discord
        signal-desktop
        
        # Media
        vlc
        spotify
        
        # Utils
        ripgrep
        fd
        bat
        eza
        fzf
        tmux
        htop
      ];
    };

    programs = {
      home-manager.enable = true;

      git = {
        enable = true;
        userName = fullName;
        userEmail = email;
        extraConfig = {
          core.editor = "nvim";
        };
      };

      zsh = {
        enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
        shellAliases = {
          ll = "ls -la";
          ".." = "cd ..";
          "..." = "cd ../..";
          g = "git";
          k = "kubectl";
        };
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
      };
      iconTheme = {
        name = "Papirus-Dark";
      };
    };

    xdg = {
      enable = true;
    };

    services = {
      gpg-agent = {
        enable = true;
        enableSshSupport = true;
      };
      
      syncthing = {
        enable = true;
      };
    };

    # Optional: Configure additional services
    # systemd.user.services = {
    #   backup = {
    #     Unit = {
    #       Description = "Backup personal files";
    #     };
    #     Service = {
    #       ExecStart = "${pkgs.rsync}/bin/rsync -av --delete ~/Documents /mnt/backup/";
    #     };
    #   };
    # };
  };
}
