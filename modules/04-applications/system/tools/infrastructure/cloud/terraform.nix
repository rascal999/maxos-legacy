{ config, lib, pkgs, ... }:

# MaxOS Terraform Tool Module (Layer 4 - Applications)
#
# This module provides Terraform infrastructure-as-code tool for managing
# cloud and on-premises infrastructure, following layered architecture conventions.

with lib;

let
  cfg = config.maxos.tools.terraform;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = 
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.terraform = {
    enable = mkEnableOption "Terraform infrastructure-as-code tool";
    
    version = mkOption {
      type = types.str;
      default = "1.6.6";
      description = "Terraform version to install";
    };
    
    enableProviders = mkOption {
      type = types.listOf types.str;
      default = [ "aws" "docker" "local" "null" ];
      description = "List of terraform providers to pre-install";
    };
    
    enableTerragrunt = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Terragrunt for DRY Terraform configurations";
    };
    
    enableTflint = mkOption {
      type = types.bool;
      default = true;
      description = "Enable TFLint for Terraform linting";
    };
    
    enableTfsec = mkOption {
      type = types.bool;
      default = true;
      description = "Enable tfsec for Terraform security scanning";
    };
    
    enableTerraformDocs = mkOption {
      type = types.bool;
      default = true;
      description = "Enable terraform-docs for documentation generation";
    };
    
    configDir = mkOption {
      type = types.str;
      default = "/home/${config.maxos.user.name}/.terraform.d";
      description = "Terraform configuration directory";
    };
    
    workspaceDir = mkOption {
      type = types.str;
      default = "/home/${config.maxos.user.name}/terraform";
      description = "Default terraform workspace directory";
    };
    
    enableZshCompletion = mkOption {
      type = types.bool;
      default = true;
      description = "Enable zsh completion for Terraform";
    };
    
    enableBashCompletion = mkOption {
      type = types.bool;
      default = true;
      description = "Enable bash completion for Terraform";
    };
    
    enableVSCodeIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Enable VSCode Terraform extension recommendations";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS terraform tool requires user module to be enabled";
      }
    ];

    # Install Terraform and related tools
    environment.systemPackages = with pkgs; [
      # Core Terraform
      terraform
    ] ++ optionals cfg.enableTerragrunt [
      # Terragrunt for DRY configurations
      terragrunt
    ] ++ optionals cfg.enableTflint [
      # TFLint for Terraform linting
      tflint
    ] ++ optionals cfg.enableTfsec [
      # tfsec for security scanning
      tfsec
    ] ++ optionals cfg.enableTerraformDocs [
      # terraform-docs for documentation
      terraform-docs
    ];

    # Enable shell completions
    programs.bash.completion.enable = mkIf cfg.enableBashCompletion true;
    programs.zsh.enable = mkIf cfg.enableZshCompletion true;
    
    # Environment variables for Terraform
    environment.variables = {
      # Set Terraform configuration directory
      TF_DATA_DIR = "${cfg.configDir}";
      # Enable detailed logging (can be overridden)
      TF_LOG = "WARN";
      # Set plugin cache directory to speed up init
      TF_PLUGIN_CACHE_DIR = "${cfg.configDir}/plugin-cache";
    };
    
    # Create Terraform directories with proper permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0755 ${config.maxos.user.name} users -"
      "d ${cfg.configDir}/plugin-cache 0755 ${config.maxos.user.name} users -"
      "d ${cfg.workspaceDir} 0755 ${config.maxos.user.name} users -"
    ];
    
    # Configure aliases (completion disabled to avoid early shell init issues)
    environment.shellInit = ''
      # Terraform completion disabled - causes issues in /etc/zshenv
      # Users can enable completion manually in their shell config if needed
      
      # Terraform aliases for common operations
      alias tf='terraform'
      alias tfi='terraform init'
      alias tfp='terraform plan'
      alias tfa='terraform apply'
      alias tfd='terraform destroy'
      alias tfs='terraform show'
      alias tfv='terraform validate'
      alias tff='terraform fmt'
      alias tfws='terraform workspace'
      
      # Terragrunt aliases
      ${optionalString cfg.enableTerragrunt ''
        alias tg='terragrunt'
        alias tgi='terragrunt init'
        alias tgp='terragrunt plan'
        alias tga='terragrunt apply'
        alias tgd='terragrunt destroy'
        alias tgpa='terragrunt plan-all'
        alias tgaa='terragrunt apply-all'
        alias tgda='terragrunt destroy-all'
      ''}
    '';
    
    # VSCode integration and TFLint configuration
    environment.etc = mkMerge [
      (mkIf cfg.enableVSCodeIntegration {
        "vscode-terraform-extensions.json".text = builtins.toJSON {
          recommendations = [
            "hashicorp.terraform"
            "ms-vscode.vscode-json"
            "redhat.vscode-yaml"
          ];
        };
      })
      (mkIf cfg.enableTflint {
        "tflint/config.hcl".text = ''
        config {
          module = true
          force = false
        }
        
        plugin "aws" {
          enabled = ${if builtins.elem "aws" cfg.enableProviders then "true" else "false"}
          version = "0.21.2"
          source  = "github.com/terraform-linters/tflint-ruleset-aws"
        }
        
        rule "terraform_deprecated_interpolation" {
          enabled = true
        }
        
        rule "terraform_unused_declarations" {
          enabled = true
        }
        
        rule "terraform_comment_syntax" {
          enabled = true
        }
        
        rule "terraform_documented_outputs" {
          enabled = true
        }
        
        rule "terraform_documented_variables" {
          enabled = true
        }
        
        rule "terraform_typed_variables" {
          enabled = true
        }
        
        rule "terraform_module_pinned_source" {
          enabled = true
        }
        
        rule "terraform_naming_convention" {
          enabled = true
          format  = "snake_case"
        }
        
        rule "terraform_standard_module_structure" {
          enabled = true
        }
      '';
    })
  ];
  };
}