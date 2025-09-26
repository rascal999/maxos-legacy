{ config, lib, pkgs, ... }:

# MaxOS AWS CLI Tool Module (Layer 4 - Applications)
#
# This module provides the AWS Command Line Interface for managing AWS services,
# following layered architecture conventions.

with lib;

let
  cfg = config.maxos.tools.aws-cli;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.aws-cli = {
    enable = mkEnableOption "AWS CLI command line interface";
    
    version = mkOption {
      type = types.enum [ "v1" "v2" ];
      default = "v2";
      description = "AWS CLI version to install";
    };
    
    enableSessionManager = mkOption {
      type = types.bool;
      default = true;
      description = "Enable AWS Systems Manager Session Manager plugin";
    };
    
    enableSAM = mkOption {
      type = types.bool;
      default = false;
      description = "Enable AWS SAM (Serverless Application Model) CLI";
    };
    
    enableCDK = mkOption {
      type = types.bool;
      default = false;
      description = "Enable AWS CDK (Cloud Development Kit)";
    };
    
    configDir = mkOption {
      type = types.str;
      default = "/home/${config.maxos.user.name}/.aws";
      description = "AWS configuration directory";
    };
    
    enableZshCompletion = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh completion for AWS CLI";
    };
    
    enableBashCompletion = mkOption {
      type = types.bool;
      default = true;
      description = "Enable bash completion for AWS CLI";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS aws-cli tool requires user module to be enabled";
      }
    ];

    # Install AWS CLI and related tools
    environment.systemPackages = with pkgs; [
      # AWS CLI (version 2 by default)
      (if cfg.version == "v2" then awscli2 else awscli)
    ] ++ optionals cfg.enableSessionManager [
      # AWS Systems Manager Session Manager plugin
      awscli2
    ] ++ optionals cfg.enableSAM [
      # AWS SAM CLI
      awscli2
    ] ++ optionals cfg.enableCDK [
      # AWS CDK
      nodePackages.aws-cdk
    ];

    # Enable shell completions
    programs.bash.completion.enable = mkIf cfg.enableBashCompletion true;
    programs.zsh.enable = mkIf cfg.enableZshCompletion true;
    
    # Environment variables for AWS CLI
    environment.variables = {
      # Set default AWS config directory
      AWS_CONFIG_FILE = "${cfg.configDir}/config";
      AWS_SHARED_CREDENTIALS_FILE = "${cfg.configDir}/credentials";
      # Enable CLI auto-prompt for better UX
      AWS_CLI_AUTO_PROMPT = "on-partial";
    };
    
    # Create AWS config directory with proper permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0700 ${config.maxos.user.name} users -"
    ];
    
    # Configure shell completions and aliases
    environment.shellInit = mkIf cfg.enableBashCompletion ''
      # AWS CLI completion for bash
      if [ -n "$BASH_VERSION" ] && command -v aws >/dev/null 2>&1; then
        complete -C '${if cfg.version == "v2" then pkgs.awscli2 else pkgs.awscli}/bin/aws_completer' aws
      fi
    '';
  };
}