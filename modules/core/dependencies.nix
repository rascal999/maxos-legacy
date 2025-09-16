# Smart Conditional Dependencies System for MaxOS
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.dependencies;
  
  # Define tool dependencies and relationships
  toolDependencies = {
    # Container and orchestration dependencies
    kind = {
      requires = [ "docker" ];
      description = "Kind requires Docker to create Kubernetes clusters";
    };
    
    kubectl = {
      suggests = [ "k3s" "kind" ];
      description = "kubectl is useful with Kubernetes clusters";
    };
    
    docker-compose = {
      requires = [ "docker" ];
      description = "Docker Compose requires Docker daemon";
      autoEnable = true; # Automatically enable when docker is enabled
    };
    
    # Development workflow dependencies
    gitleaks = {
      suggests = [ "git" ];
      description = "gitleaks works with Git repositories for secret scanning";
    };
    
    git-crypt = {
      requires = [ "git" ];
      description = "git-crypt extends Git with encryption capabilities";
    };
    
    # Database and application dependencies
    grafana = {
      suggests = [ "prometheus" ];
      description = "Grafana works well with Prometheus for monitoring";
    };
    
    # Backup dependencies
    restic = {
      suggests = [ "docker" ];
      description = "Restic can backup Docker volumes and containers";
    };
    
    # Security tool relationships
    trivy = {
      suggests = [ "docker" ];
      description = "Trivy can scan Docker images for vulnerabilities";
    };
    
    semgrep = {
      suggests = [ "git" ];
      description = "Semgrep works best with Git repositories";
    };
    
    # Terminal and shell dependencies
    tmux = {
      suggests = [ "zsh" "alacritty" ];
      description = "tmux enhances terminal workflow";
    };
    
    # Editor and development
    vscode = {
      suggests = [ "git" "docker" ];
      description = "VSCode integrates with Git and Docker";
    };
    
    # Network and server tools
    traefik = {
      suggests = [ "docker" "k3s" ];
      description = "Traefik works as reverse proxy for containers and Kubernetes";
    };
    
    blocky = {
      suggests = [ "docker" ];
      description = "Blocky can run as Docker container";
    };
    
    # AI/ML dependencies
    open-webui = {
      requires = [ "ollama" ];
      description = "Open WebUI requires Ollama for LLM functionality";
      autoEnable = true;
    };
    
    # Forgejo ecosystem
    forgejo-runner = {
      requires = [ "forgejo" "docker" ];
      description = "Forgejo runner requires Forgejo server and Docker for CI/CD";
    };
    
    forgejo-cli = {
      suggests = [ "forgejo" ];
      description = "Forgejo CLI works with Forgejo server";
    };
  };
  
  # Get currently enabled tools
  getEnabledTools = config:
    let
      tools = config.modules.tools or {};
    in
    builtins.filter (name: 
      let toolConfig = tools.${name} or {};
      in toolConfig ? enable && toolConfig.enable
    ) (builtins.attrNames tools);
  
  # Check dependencies and generate automatic enablements
  checkDependencies = enabledTools:
    let
      # Check required dependencies
      missingRequired = builtins.filter (toolName:
        let
          deps = toolDependencies.${toolName} or {};
          required = deps.requires or [];
        in
        required != [] && !(builtins.all (dep: builtins.elem dep enabledTools) required)
      ) enabledTools;
      
      # Get tools that should be auto-enabled
      autoEnableTools = builtins.filter (toolName:
        let
          deps = toolDependencies.${toolName} or {};
          required = deps.requires or [];
          autoEnable = deps.autoEnable or false;
        in
        autoEnable && builtins.all (dep: builtins.elem dep enabledTools) required
      ) (builtins.attrNames toolDependencies);
      
      # Get suggested tools
      suggestedTools = let
        allSuggestions = builtins.concatLists (builtins.map (toolName:
          let deps = toolDependencies.${toolName} or {};
          in if builtins.elem toolName enabledTools 
             then deps.suggests or []
             else []
        ) (builtins.attrNames toolDependencies));
      in lib.unique (builtins.filter (tool: 
        !builtins.elem tool enabledTools
      ) allSuggestions);
      
    in {
      inherit missingRequired autoEnableTools suggestedTools;
    };

in {
  options.maxos.dependencies = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable smart dependency management";
    };
    
    autoEnable = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically enable required dependencies";
    };
    
    warnMissing = mkOption {
      type = types.bool;
      default = true;
      description = "Warn about missing required dependencies";
    };
    
    suggestRelated = mkOption {
      type = types.bool;
      default = true;
      description = "Suggest related tools that might be useful";
    };
  };

  config = mkIf cfg.enable {
    # Auto-enablements disabled for now - no valid modules to auto-enable
    # Will add back when docker-compose and open-webui modules exist
    # modules.tools = mkIf cfg.autoEnable {
    # };
    
    # Add basic warnings for common dependency issues  
    warnings = mkIf cfg.warnMissing [
      (mkIf ((config.modules.tools.kind.enable or false) && !(config.modules.tools.docker.enable or false))
        "Kind is enabled but Docker is not - Kind requires Docker to function properly")
      (mkIf ((config.modules.tools.forgejo-runner.enable or false) && !(config.modules.tools.forgejo.enable or false))
        "Forgejo runner is enabled but Forgejo server is not - Consider enabling forgejo")
    ];
    
    # Add dependency report without complex evaluation
    system.build.dependencyInfo = pkgs.writeText "dependency-info" (
      "MaxOS Dependency System\n" +
      "=======================\n\n" +
      "Known tool dependencies:\n" +
      (builtins.concatStringsSep "\n" (lib.mapAttrsToList (tool: deps:
        "  ${tool}: ${deps.description or "No description"}" +
        (if deps ? requires then " (requires: ${builtins.concatStringsSep ", " deps.requires})" else "") +
        (if deps ? suggests then " (suggests: ${builtins.concatStringsSep ", " deps.suggests})" else "")
      ) toolDependencies))
    );
  };
}