# Hybrid Docker module - works in both NixOS and home-manager contexts
{ config, lib, pkgs, osConfig ? {}, ... }:

with lib;

let
  cfg = config.modules.tools.docker;
  # Detect if we're in home-manager context
  # In home-manager context, osConfig exists and contains system config
  # In system context, osConfig is empty and config has system options
  isHomeManager = osConfig != {} && osConfig ? maxos && !(config ? nixpkgs);
  # Get unified user config
  userConfig = if isHomeManager then osConfig.maxos.user else config.maxos.user;
  
in {
  options.modules.tools.docker = {
    enable = mkEnableOption "Docker containerization platform";
    
    enableCompose = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Docker Compose";
    };
    
    enableBuildx = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Docker Buildx";
    };
    
    liveRestore = mkOption {
      type = types.bool;
      default = false;
      description = "Enable live restore to keep containers running during daemon restarts";
    };
    
    enableExperimental = mkOption {
      type = types.bool;
      default = false;
      description = "Enable experimental Docker features";
    };
    
    registryMirrors = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of registry mirrors";
      example = [ "https://mirror.example.com" ];
    };
    
    aliases = mkOption {
      type = types.attrs;
      default = {
        dps = "docker ps";
        dim = "docker images";
        dex = "docker exec -it";
        dlog = "docker logs -f";
        dstop = "docker stop $(docker ps -q)";
        drm = "docker rm $(docker ps -aq)";
        drmi = "docker rmi $(docker images -q)";
        dprune = "docker system prune -af";
      };
      description = "Docker shell aliases";
    };
  };

  config = mkIf cfg.enable (mkMerge ([
    # Home-manager configuration (user-level tools and aliases)
  ] ++ optionals isHomeManager [{
      home.packages = with pkgs; [
        docker
      ] ++ optionals cfg.enableCompose [ docker-compose ]
        ++ optionals cfg.enableBuildx [ docker-buildx ];
      
      # Add Docker aliases to shell
      programs.bash.shellAliases = cfg.aliases;
      programs.zsh.shellAliases = cfg.aliases;
      programs.fish.shellAliases = cfg.aliases;
      
      # User-specific Docker configuration
      xdg.configFile."docker/config.json".text = builtins.toJSON {
        experimental = if cfg.enableExperimental then "enabled" else "disabled";
        registry-mirrors = cfg.registryMirrors;
      };
    }] ++ optionals (!isHomeManager) [{
    # System-level configuration (daemon and service)
      virtualisation.docker = {
        enable = true;
        liveRestore = cfg.liveRestore;
        enableOnBoot = true;
        
        daemon.settings = {
          experimental = cfg.enableExperimental;
          registry-mirrors = cfg.registryMirrors;
        };
      };
      
      # Add user to docker group
      users.users.${userConfig.name}.extraGroups = [ "docker" ];
      
      environment.systemPackages = with pkgs; [
        docker
      ] ++ optionals cfg.enableCompose [ docker-compose ]
        ++ optionals cfg.enableBuildx [ docker-buildx ];
      
      # System-wide Docker network setup
      systemd.services.docker-network-setup = {
        description = "Setup Docker networks";
        after = [ "docker.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          # Wait for Docker daemon to be ready
          while ! ${pkgs.docker}/bin/docker system info >/dev/null 2>&1; do
            sleep 1
          done
          
          # Create default networks if they don't exist
          ${pkgs.docker}/bin/docker network ls | grep maxos-default || \
            ${pkgs.docker}/bin/docker network create maxos-default
        '';
      };
    }]));
}