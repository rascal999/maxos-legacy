# System-only Git module following layered architecture
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.git;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
  userConfig = config.maxos.user;
  
in {
  options.maxos.git = {
    enable = mkEnableOption "Git version control system";
    
    userName = mkOption {
      type = types.str;
      default = userConfig.fullName or "MaxOS User";
      description = "Git user name";
    };
    
    userEmail = mkOption {
      type = types.str;
      default = userConfig.email or "user@example.com";
      description = "Git user email";
    };
    
    defaultBranch = mkOption {
      type = types.str;
      default = "main";
      description = "Default branch name for new repositories";
    };
    
    enableLFS = mkOption {
      type = types.bool;
      default = false;
      description = "Enable Git Large File Storage";
    };
    
    enableCrypt = mkOption {
      type = types.bool;
      default = false;
      description = "Enable git-crypt for encrypted files";
    };
    
    enableLeaksDetection = mkOption {
      type = types.bool;
      default = true;
      description = "Enable gitleaks for secrets detection";
    };
    
    extraConfig = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional Git configuration";
      example = {
        pull.rebase = true;
        core.editor = "nvim";
      };
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    # System-level configuration only
    programs.git = {
      enable = true;
      config = {
        init.defaultBranch = cfg.defaultBranch;
        user.name = cfg.userName;
        user.email = cfg.userEmail;
        pull.rebase = mkDefault true;
        push.autoSetupRemote = mkDefault true;
        core.autocrlf = mkDefault "input";
      } // cfg.extraConfig;
      
      lfs.enable = cfg.enableLFS;
    };
    
    environment.systemPackages = with pkgs; [
      git
    ] ++ optionals cfg.enableCrypt [ git-crypt ]
      ++ optionals cfg.enableLeaksDetection [ gitleaks ]
      ++ optionals cfg.enableLFS [ git-lfs ];
    
    # System-wide git hooks directory
    environment.etc."git/hooks" = mkIf cfg.enableLeaksDetection {
      source = pkgs.writeTextDir "pre-commit" ''
        #!/bin/sh
        ${pkgs.gitleaks}/bin/gitleaks protect --verbose --redact --staged
      '';
    };
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Git requires user module";
      }
    ];
  };
}