{ config, pkgs, lib, ... }:

{
  programs.git = {
    enable = true;
    
    # Basic user configuration
    userName = "user";  # Will be overridden by machine-specific config
    userEmail = "user@example.com";  # Will be overridden by machine-specific config
    
    # Default settings
    extraConfig = {
      init.defaultBranch = "main";
      
      # Better diffs
      diff = {
        algorithm = "histogram";
        colorMoved = "default";
      };
      
      # Helpful aliases
      alias = {
        # Logging
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        recent = "for-each-ref --sort=-committerdate --format='%(committerdate:short) %(refname:short)' refs/heads/";
        
        # Status/info
        st = "status -sb";
        br = "branch -vv";
        
        # Operations
        co = "checkout";
        cb = "checkout -b";
        cm = "commit -m";
        ca = "commit --amend";
        unstage = "reset HEAD --";
        undo = "reset --soft HEAD^";
        
        # Stash operations
        sl = "stash list";
        sa = "stash apply";
        ss = "stash save";
        
        # Advanced
        conflicts = "diff --name-only --diff-filter=U";
        local-branches = "!git branch -vv | cut -c 3- | awk '$3 !~/\\[/ { print $1 }'";
        recent-branches = "!git branch --sort=-committerdate | head";
      };
      
      # Better merge conflict information
      merge = {
        conflictStyle = "diff3";
        tool = "nvimdiff";
      };
      
      # Helpful UI improvements
      color = {
        ui = true;
        diff = {
          meta = "yellow bold";
          commit = "green bold";
          frag = "magenta bold";
          old = "red bold";
          new = "green bold";
          whitespace = "red reverse";
        };
        status = {
          added = "green";
          changed = "yellow";
          untracked = "red";
        };
        branch = {
          current = "yellow reverse";
          local = "yellow";
          remote = "green";
        };
      };
      
      # Performance improvements
      core = {
        # Use persistent git credentials
        askPass = "";
        # Ignore file permission changes
        fileMode = false;
        # Enable parallel index preload for operations like git diff
        preloadIndex = true;
        # Use UTF-8 by default
        quotePath = false;
      };
      
      # Push behavior
      push = {
        # Push only the current branch
        default = "current";
        # Push tags automatically
        followTags = true;
      };
      
      # Pull behavior
      pull = {
        # Rebase by default
        rebase = true;
      };
      
      # Helpful settings
      help = {
        # Automatically correct mistyped commands
        autocorrect = 1;
      };
    };
    
    # Delta configuration for better diffs
    delta = {
      enable = true;
      options = {
        features = "decorations";
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        syntax-theme = "Dracula";
      };
    };
    
    # Useful git ignores
    ignores = [
      # Nix
      "result"
      "result-*"
      
      # Editor files
      ".vscode"
      ".idea"
      "*.swp"
      "*.swo"
      "*~"
      
      # OS files
      ".DS_Store"
      "Thumbs.db"
      
      # Common build directories
      "dist"
      "build"
      ".next"
      
      # Dependencies
      "node_modules"
      ".direnv"
    ];
  };
}
