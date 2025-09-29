{ config, lib, pkgs, ... }:

# MaxOS Redis Service Wrapper (Layer 3 - Services)
#
# This module wraps the standard NixOS Redis service with MaxOS-specific
# configuration options, following layered architecture.

with lib;

let
  cfg = config.maxos.tools.redis;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.redis = {
    enable = mkEnableOption "Redis in-memory data store";
    
    port = mkOption {
      type = types.port;
      default = 6379;
      description = "Port on which Redis will listen";
    };
    
    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Interface on which Redis will listen";
    };
    
    requirePass = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Password required for Redis authentication (null for no authentication)";
    };
    
    maxMemory = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "1gb";
      description = "Maximum memory Redis is allowed to use (e.g., '1gb', '512mb')";
    };
    
    maxMemoryPolicy = mkOption {
      type = types.enum [ "noeviction" "allkeys-lru" "volatile-lru" "allkeys-random" "volatile-random" "volatile-ttl" "volatile-lfu" "allkeys-lfu" ];
      default = "noeviction";
      description = "Policy for handling memory limits";
    };
    
    save = mkOption {
      type = types.listOf types.str;
      default = [ "900 1" "300 10" "60 10000" ];
      description = "List of save conditions for RDB snapshots (seconds changes)";
    };
    
    appendOnly = mkOption {
      type = types.bool;
      default = false;
      description = "Enable append-only file (AOF) persistence";
    };
    
    databases = mkOption {
      type = types.ints.positive;
      default = 16;
      description = "Number of Redis databases";
    };
    
    logLevel = mkOption {
      type = types.enum [ "debug" "verbose" "notice" "warning" ];
      default = "notice";
      description = "Redis log level";
    };
    
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall port for Redis (only enable for external access)";
    };
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional Redis configuration";
    };
    
    redisInsight = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable RedisInsight web-based Redis GUI";
      };
      
      port = mkOption {
        type = types.port;
        default = 8001;
        description = "Port for RedisInsight web interface";
      };
      
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Host for RedisInsight web interface";
      };
      
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall for RedisInsight (only enable for external access)";
      };
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS Redis wrapper requires user module to be enabled";
      }
      {
        assertion = cfg.bind != "0.0.0.0" || cfg.openFirewall;
        message = "Redis binding to all interfaces (0.0.0.0) requires openFirewall to be explicitly enabled";
      }
    ];

    # Use standard NixOS Redis service with MaxOS enhancements
    services.redis.servers.default = {
      enable = true;
      port = cfg.port;
      bind = cfg.bind;
      requirePass = cfg.requirePass;
      
      # Memory configuration
      settings = {
        maxmemory = mkIf (cfg.maxMemory != null) cfg.maxMemory;
        maxmemory-policy = cfg.maxMemoryPolicy;
        
        # Persistence configuration
        save = cfg.save;
        appendonly = if cfg.appendOnly then "yes" else "no";
        
        # Database configuration
        databases = cfg.databases;
        
        # Logging configuration
        loglevel = cfg.logLevel;
        
        # Security enhancements
        protected-mode = if cfg.bind == "127.0.0.1" then "yes" else "no";
        
        # Performance optimizations
        tcp-keepalive = 300;
        timeout = 0;
        
        # Additional configuration
      } // (if cfg.extraConfig != "" then {
        # Parse extra config into settings if needed
        # For now, we'll use the extraConfig as-is in the config file
      } else {});
      
      # Add extra configuration directly
      extraParams = lib.optionals (cfg.extraConfig != "") [ cfg.extraConfig ];
    };
    
    # MaxOS-specific enhancements
    environment.systemPackages = with pkgs; [
      redis  # Include redis-cli and other tools
    ] ++ lib.optionals cfg.redisInsight.enable [
      redisinsight  # Native RedisInsight package
    ];
    
    # RedisInsight as a native systemd service
    systemd.services.redisinsight = mkIf cfg.redisInsight.enable {
      description = "RedisInsight web-based Redis GUI";
      after = [ "redis-default.service" "network-online.target" ];
      wants = [ "redis-default.service" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      
      environment = {
        REDISINSIGHT_HOST = cfg.redisInsight.host;
        REDISINSIGHT_PORT = toString cfg.redisInsight.port;
        REDISINSIGHT_DATA_DIR = "/var/lib/redisinsight";
      };
      
      serviceConfig = {
        Type = "simple";
        User = "redisinsight";
        Group = "redisinsight";
        ExecStart = "${pkgs.redisinsight}/bin/redisinsight";
        Restart = "always";
        RestartSec = "5s";
        StateDirectory = "redisinsight";
        StateDirectoryMode = "0755";
        WorkingDirectory = "/var/lib/redisinsight";
        
        # Security hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        LockPersonality = true;
      };
    };
    
    # Create redisinsight user and group
    users.users.redisinsight = mkIf cfg.redisInsight.enable {
      isSystemUser = true;
      group = "redisinsight";
      description = "RedisInsight service user";
    };
    
    users.groups.redisinsight = mkIf cfg.redisInsight.enable {};

    # Configure firewall if external access is needed
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ] ++ lib.optionals cfg.redisInsight.openFirewall [ cfg.redisInsight.port ];
    };
    
    # Ensure Redis starts after network is ready
    systemd.services.redis-default = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
    
    # Add useful environment variables
    environment.variables = {
      REDIS_URL = "redis://${cfg.bind}:${toString cfg.port}";
    };
  };
}