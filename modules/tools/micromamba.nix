{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.micromamba;
in {
  options.modules.tools.micromamba = {
    enable = mkEnableOption "micromamba configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      micromamba
    ];

    # Add shell configuration
    programs.zsh.initExtra = ''
      # >>> mamba initialize >>>
      export MAMBA_ROOT_PREFIX="$HOME/micromamba"
      eval "$(micromamba shell hook --shell=zsh)"
      # <<< mamba initialize <<<
    '';

    programs.bash.initExtra = ''
      # >>> mamba initialize >>>
      export MAMBA_ROOT_PREFIX="$HOME/micromamba"
      eval "$(micromamba shell hook --shell=bash)"
      # <<< mamba initialize <<<
    '';

    # Create micromamba root directory
    home.file.".micromamba/.keep".text = "";
  };
}