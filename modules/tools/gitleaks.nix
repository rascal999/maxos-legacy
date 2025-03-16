{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.gitleaks;
  
  # Create the pre-push hook script
  hookScript = pkgs.writeTextFile {
    name = "pre-push";
    text = ''
      #!/usr/bin/env bash

      echo "Running Gitleaks pre-push hook..."
      ${if cfg.configFile != null then
        "gitleaks detect --source . --config ${cfg.configFile} --verbose"
      else
        "gitleaks detect --source . --verbose"
      }

      if [ $? -ne 0 ]; then
        echo "Gitleaks detected potential secrets in your code. Push aborted."
        echo "Please fix the issues and try again."
        exit 1
      fi

      exit 0
    '';
    executable = true;
  };
  
  # Create a git wrapper script that sets up the hooks
  gitWrapper = pkgs.writeScriptBin "git" ''
    #!/usr/bin/env bash
    
    # Set GIT_TEMPLATE_DIR to include our hooks
    export GIT_TEMPLATE_DIR=${pkgs.symlinkJoin {
      name = "git-template-dir";
      paths = [
        "${pkgs.git}/share/git-core/templates"
        (pkgs.runCommand "gitleaks-hooks" {} ''
          mkdir -p $out/hooks
          ln -s ${hookScript} $out/hooks/pre-push
        '')
      ];
    }}
    
    # Execute the real git command
    exec ${pkgs.git}/bin/git "$@"
  '';
  
  # Create a setup script for existing repositories
  setupScript = pkgs.writeScriptBin "setup-gitleaks-hooks" ''
    #!/usr/bin/env bash
    
    if [ -z "$1" ]; then
      echo "Usage: setup-gitleaks-hooks <repository-path>"
      echo "Sets up Gitleaks pre-push hooks in the specified git repository."
      exit 1
    fi
    
    REPO_PATH="$1"
    
    if [ ! -d "$REPO_PATH/.git" ]; then
      echo "Error: $REPO_PATH is not a git repository."
      exit 1
    fi
    
    HOOKS_DIR="$REPO_PATH/.git/hooks"
    mkdir -p "$HOOKS_DIR"
    
    echo "Installing Gitleaks pre-push hook in $REPO_PATH..."
    ln -sf ${hookScript} "$HOOKS_DIR/pre-push"
    
    echo "Gitleaks pre-push hook installed successfully."
  '';
  
in {
  options.modules.tools.gitleaks = {
    enable = mkEnableOption "Enable Gitleaks for secret scanning";
    
    installGitHook = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install the pre-push git hook globally";
    };
    
    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a custom Gitleaks configuration file";
    };
  };

  config = mkIf cfg.enable {
    # Install Gitleaks package and our custom scripts
    environment.systemPackages = [
      pkgs.gitleaks
      setupScript
    ] ++ (if cfg.installGitHook then [ gitWrapper ] else []);
    
    # Add documentation
    environment.etc."gitleaks-readme".text = ''
      # Gitleaks Configuration
      
      Gitleaks has been installed on this system to prevent accidental leaking of secrets.
      
      ## Pre-push Hook
      
      ${if cfg.installGitHook then ''
        A global git wrapper has been installed that automatically sets up the pre-push hook
        for new repositories. When you run 'git init' or 'git clone', the hook will be set up.
        
        For existing repositories, you can run:
        
        ```
        setup-gitleaks-hooks /path/to/repository
        ```
      '' else ''
        To set up the pre-push hook for a repository, run:
        
        ```
        setup-gitleaks-hooks /path/to/repository
        ```
      ''}
      
      The hook will scan your code before pushing to remote repositories.
      If Gitleaks detects any potential secrets, the push will be aborted.
      
      ## Manual Usage
      
      You can also run Gitleaks manually:
      
      ```
      gitleaks detect --source /path/to/repo --verbose
      ```
      
      ## Custom Configuration
      
      To use a custom configuration, create a gitleaks.toml file and specify its path in your NixOS configuration:
      
      ```nix
      modules.tools.gitleaks = {
        enable = true;
        configFile = /path/to/gitleaks.toml;
      };
      ```
    '';
  };
}