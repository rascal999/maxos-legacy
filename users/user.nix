# Default User Configuration Template
{ config, pkgs, lib, ... }:

let
  username = "user";
  fullName = "Example User";
  email = "user@example.com";
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
    hashedPassword = null;
    # SSH keys are managed centrally through the ssh-keys module
    shell = pkgs.zsh;
  };

  home-manager.users.${username} = { pkgs, ... }: {
    home = {
      stateVersion = "23.11";
      username = username;
      homeDirectory = "/home/${username}";
      
      packages = with pkgs; [
        python3
        nodejs
        vscode
        htop
        ripgrep
        fd
        bat
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
        };
      };

      alacritty = {
        enable = true;
        settings = {
          font.size = lib.mkForce 16.0;
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
      gpg-agent.enable = false;
    };
  };
}
