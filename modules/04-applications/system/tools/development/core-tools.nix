{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.development-core;
in {
  options.maxos.tools.development-core = {
    enable = mkEnableOption "Core development tools (git, neovim, ripgrep, etc.)";
    
    includeGitHub = mkOption {
      type = types.bool;
      default = true;
      description = "Include GitHub CLI (gh)";
    };
    
    includeSearchTools = mkOption {
      type = types.bool;
      default = true;
      description = "Include search tools (ripgrep, fd)";
    };
    
    includeUtilities = mkOption {
      type = types.bool;
      default = true;
      description = "Include utility tools (jq, tree, pwgen)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Core development tools
      git
      neovim
    ] ++ optionals cfg.includeGitHub [
      gh
    ] ++ optionals cfg.includeSearchTools [
      ripgrep
      fd
    ] ++ optionals cfg.includeUtilities [
      jq
      tree
      pwgen
    ];

    # Git configuration at system level
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };
}