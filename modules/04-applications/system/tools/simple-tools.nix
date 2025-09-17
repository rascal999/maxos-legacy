# Auto-generated simple tool modules using tool generator
{ lib }:

let
  toolGenerator = import ../../lib/tool-generator.nix { inherit lib; };
in
{
  # Simple package-only tools
  keepassxc = toolGenerator.generateSimpleTool {
    toolName = "keepassxc";
    packages = pkgs: with pkgs; [ keepassxc ];
    description = "KeePassXC password manager";
  };

  chromium = toolGenerator.generateSimpleTool {
    toolName = "chromium"; 
    packages = pkgs: with pkgs; [ chromium ];
    description = "Chromium web browser";
  };

  qdirstat = toolGenerator.generateSimpleTool {
    toolName = "qdirstat";
    packages = pkgs: with pkgs; [ qdirstat ];
    description = "QDirStat (Qt-based directory statistics tool)";
  };

  simplescreenrecorder = toolGenerator.generateSimpleTool {
    toolName = "simplescreenrecorder";
    packages = pkgs: with pkgs; [ simplescreenrecorder ];
    description = "Simple Screen Recorder";
  };

  mosh = toolGenerator.generateSimpleTool {
    toolName = "mosh";
    packages = pkgs: with pkgs; [ mosh ];
    description = "Mosh (mobile shell)";
  };

  sshfs = toolGenerator.generateSimpleTool {
    toolName = "sshfs";
    packages = pkgs: with pkgs; [ sshfs ];
    description = "SSHFS - SSH filesystem";
  };


  linuxquota = toolGenerator.generateSimpleTool {
    toolName = "linuxquota";
    packages = pkgs: with pkgs; [ quota ];
    description = "Linux quota management tools";
  };

  # Development tools with shell integration
  golang = toolGenerator.generateDevTool {
    toolName = "golang";
    packages = pkgs: with pkgs; [ go ];
    description = "Go programming language";
    envVars = {
      GOPATH = "$HOME/go";
      GOBIN = "$HOME/go/bin";
    };
    shellInit = ''
      # Add Go bin to PATH
      export PATH="$HOME/go/bin:$PATH"
    '';
  };

  # Security tools
  semgrep = toolGenerator.generateSimpleTool {
    toolName = "semgrep";
    packages = pkgs: with pkgs; [ semgrep ];
    description = "Semgrep static analysis tool";
  };

  grype = toolGenerator.generateSimpleTool {
    toolName = "grype";
    packages = pkgs: with pkgs; [ grype ];
    description = "Grype vulnerability scanner";
  };

  syft = toolGenerator.generateSimpleTool {
    toolName = "syft";
    packages = pkgs: with pkgs; [ syft ];
    description = "Syft SBOM generator";
  };

  trivy = toolGenerator.generateSimpleTool {
    toolName = "trivy";
    packages = pkgs: with pkgs; [ trivy ];
    description = "Trivy vulnerability scanner";
  };

  gitleaks = toolGenerator.generateSimpleTool {
    toolName = "gitleaks";
    packages = pkgs: with pkgs; [ gitleaks ];
    description = "Gitleaks secret scanner";
  };

  git-crypt = toolGenerator.generateSimpleTool {
    toolName = "git-crypt";
    packages = pkgs: with pkgs; [ git-crypt ];
    description = "Git-crypt transparent file encryption";
  };

  # DevOps tools

  skaffold = toolGenerator.generateSimpleTool {
    toolName = "skaffold";
    packages = pkgs: with pkgs; [ skaffold ];
    description = "Skaffold for Kubernetes development";
  };

  kind = toolGenerator.generateSimpleTool {
    toolName = "kind";
    packages = pkgs: with pkgs; [ kind ];
    description = "Kind (Kubernetes in Docker)";
  };

  argocd = toolGenerator.generateSimpleTool {
    toolName = "argocd";
    packages = pkgs: with pkgs; [ argocd ];
    description = "Argo CD CLI";
  };

  # Development utilities  
  direnv = toolGenerator.generateDevTool {
    toolName = "direnv";
    packages = pkgs: with pkgs; [ direnv ];
    description = "direnv environment management";
    shellInit = ''
      # Initialize direnv
      eval "$(direnv hook zsh)" 2>/dev/null || true
      eval "$(direnv hook bash)" 2>/dev/null || true
    '';
  };

  openssl = toolGenerator.generateSimpleTool {
    toolName = "openssl";
    packages = pkgs: with pkgs; [ openssl ];
    description = "OpenSSL cryptographic toolkit";
  };
}