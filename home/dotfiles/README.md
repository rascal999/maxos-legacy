# Dotfiles

This directory contains dotfiles that can be managed through the dotfiles module.

## Usage

1. Add your dotfiles to this directory
2. Configure them in your user configuration using the dotfiles module
3. They will be automatically managed by home-manager

## Example Structure

```
dotfiles/
  shell/
    zshrc
    bashrc
    profile
  git/
    gitconfig
    gitignore
  vim/
    vimrc
    vim/
      plugins.vim
      mappings.vim
  scripts/
    backup.sh
    update.sh
