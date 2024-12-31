# Test VM User Configuration
{ config, pkgs, lib, ... }:

let
  username = "aidan";
  fullName = "Aidan Marlin";
  email = "aidan.marlin@gmail.com";
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
    openssh.authorizedKeys.keys = [];
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
