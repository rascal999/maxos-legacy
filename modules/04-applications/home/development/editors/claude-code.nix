{ config, lib, pkgs, ... }:

{
  # Install Claude Code
  home.packages = with pkgs; [
    claude-code
  ];

  # Create desktop entry if needed (claude-code should provide its own)
  # The package should automatically install the .desktop file
}