# Example User Configuration with Dotfiles Management
{ config, pkgs, lib, ... }:

let
  username = "example";
in {
  home-manager.users.${username} = { pkgs, ... }: {
    # Import the dotfiles module
    imports = [ 
      ../../home/common/dotfiles.nix
    ];

    # Enable and configure dotfiles management
    dotfiles = {
      enable = true;
      directory = ../../home/dotfiles;
      
      files = {
        # Shell configuration
        "zshrc" = {
          source = ../../home/dotfiles/shell/zshrc;
          target = ".zshrc";
        };
        "profile" = {
          source = ../../home/dotfiles/shell/profile;
          target = ".profile";
        };

        # Git configuration
        "gitconfig" = {
          source = ../../home/dotfiles/git/gitconfig;
          target = ".gitconfig";
          # Use copy instead of symlink if you want to allow local modifications
          method = "copy";
        };

        # Vim configuration
        "vimrc" = {
          source = ../../home/dotfiles/vim/vimrc;
          target = ".vimrc";
        };
        "vim-plugins" = {
          source = ../../home/dotfiles/vim/plugins.vim;
          target = ".vim/plugins.vim";
        };

        # Scripts
        "backup-script" = {
          source = ../../home/dotfiles/scripts/backup.sh;
          target = ".local/bin/backup";
          method = "copy";
          executable = true;
        };
      };
    };

    # Rest of your user configuration...
  };
}
