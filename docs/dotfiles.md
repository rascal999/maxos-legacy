# Dotfiles Management

This configuration system includes a dotfiles management module that leverages home-manager to track and manage dotfiles in your home directory.

## Features

- Declarative dotfiles management through Nix configuration
- Support for both symlinks and copied files
- Executable bit management for scripts
- Automatic creation of target directories
- Built-in command to list managed dotfiles

## Usage

1. Add your dotfiles to the `maxos/home/dotfiles` directory
2. Enable the dotfiles module in your user configuration
3. Declare which dotfiles to manage

### Example Configuration

```nix
{
  dotfiles = {
    enable = true;
    directory = ../../home/dotfiles;
    
    files = {
      "vimrc" = {
        source = ./dotfiles/vimrc;
        target = ".vimrc";
      };
      "gitconfig" = {
        source = ./dotfiles/gitconfig;
        target = ".gitconfig";
        method = "copy";  # Allow local modifications
      };
      "backup-script" = {
        source = ./dotfiles/scripts/backup.sh;
        target = ".local/bin/backup";
        method = "copy";
        executable = true;
      };
    };
  };
}
```

## File Management Methods

### Symlinks (default)
- Creates symbolic links from your home directory to the files in the repository
- Changes to the source files are immediately reflected
- Good for configuration you want to keep strictly in sync

### Copied Files
- Copies the files to your home directory
- Allows local modifications without affecting the repository
- Good for files you might want to customize per-machine

## Commands

- `list-dotfiles`: Shows all currently managed dotfiles and their management method

## Tips

1. Use symlinks for configuration you want to keep synchronized across machines
2. Use copied files for configuration that might need local modifications
3. Make scripts executable using the `executable = true` option
4. Organize your dotfiles in the repository by category (shell, git, vim, etc.)
5. Use the same relative paths in your home directory for clarity

## Adding New Dotfiles

1. Add the file to `maxos/home/dotfiles/`
2. Add an entry to your user configuration
3. Rebuild your configuration
4. The file will be automatically managed by home-manager

See `maxos/users/docs/dotfiles-example.nix` for a complete example configuration.
