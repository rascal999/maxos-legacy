# Hybrid Git module - works in both NixOS and home-manager contexts
{ config, lib, pkgs, osConfig ? {}, ... }:

with lib;

let
  cfg = config.modules.tools.git;
  # Detect if we're in home-manager context
  # In home-manager context, osConfig exists and contains system config
  # In system context, osConfig is empty and config has system options
  isHomeManager = osConfig != {} && osConfig ? maxos && !(config ? nixpkgs);
  # Get unified user config
  userConfig = if isHomeManager then osConfig.maxos.user else config.maxos.user;
  
in {
  options.modules.tools.git = {
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

  config = mkIf cfg.enable (mkMerge ([
    # Home-manager configuration
  ] ++ optionals isHomeManager [{
      programs.git = {
        enable = true;
        userName = cfg.userName;
        userEmail = cfg.userEmail;
        
        extraConfig = {
          init.defaultBranch = cfg.defaultBranch;
          pull.rebase = mkDefault true;
          push.autoSetupRemote = mkDefault true;
          core.autocrlf = mkDefault "input";
        } // cfg.extraConfig;
        
        lfs.enable = cfg.enableLFS;
        
        aliases = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          visual = "!gitk";
        };
      };
      
      home.packages = with pkgs; [
        git
      ] ++ optionals cfg.enableCrypt [ git-crypt ]
        ++ optionals cfg.enableLeaksDetection [ gitleaks ]
        ++ optionals cfg.enableLFS [ git-lfs ];
    }] ++ optionals (!isHomeManager) [{
    # System-level configuration
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
    }]));
}