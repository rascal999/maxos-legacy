{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.dotfiles;
  
  # Type for dotfile entries
  dotfileOpts = types.submodule {
    options = {
      source = mkOption {
        type = types.path;
        description = "Path to the source file in the repository";
      };

      target = mkOption {
        type = types.str;
        description = "Target path in $HOME (relative to home directory)";
      };

      method = mkOption {
        type = types.enum [ "symlink" "copy" ];
        default = "symlink";
        description = "How to install the dotfile - either create a symlink or copy the file";
      };

      executable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the file should be marked as executable";
      };
    };
  };

in {
  options.dotfiles = {
    enable = mkEnableOption "dotfiles management";

    files = mkOption {
      type = types.attrsOf dotfileOpts;
      default = {};
      description = "Attribute set of dotfiles to manage";
      example = literalExpression ''
        {
          "vimrc" = {
            source = ./dotfiles/vimrc;
            target = ".vimrc";
          };
          "gitconfig" = {
            source = ./dotfiles/gitconfig;
            target = ".gitconfig";
            method = "copy";
          };
          "scripts/backup" = {
            source = ./dotfiles/scripts/backup.sh;
            target = ".local/bin/backup";
            method = "copy";
            executable = true;
          };
        }
      '';
    };

    # Directory in the repository where dotfiles are stored
    directory = mkOption {
      type = types.path;
      description = "Directory containing the dotfiles";
      example = literalExpression "./dotfiles";
    };
  };

  config = mkIf cfg.enable {
    # Use home-manager's file management
    home.file = mapAttrs (name: file:
      {
        source = file.source;
        target = file.target;
        executable = file.executable;
      } // (if file.method == "symlink"
        then { source = file.source; }
        else { text = builtins.readFile file.source; }
      )
    ) cfg.files;

    # Add a convenient script to list managed dotfiles
    home.packages = [
      (pkgs.writeScriptBin "list-dotfiles" ''
        #!${pkgs.runtimeShell}
        echo "Managed dotfiles:"
        echo "----------------"
        ${concatStringsSep "\n" (mapAttrsToList (name: file: ''
          echo "${file.target} (${file.method})"
        '') cfg.files)}
      '')
    ];
  };
}
