{ config, lib, pkgs, ... }:

# MaxOS MongoDB Community Edition Service Wrapper (Layer 3 - Services)
#
# This module wraps the standard NixOS MongoDB service with MaxOS-specific
# configuration options, following layered architecture.

with lib;

let
  cfg = config.maxos.tools.mongodb-ce;
  
  # Validate dependencies exist before referencing them
  dependenciesValid =
    config.maxos.user.enable or true;
    
in {
  options.maxos.tools.mongodb-ce = {
    enable = mkEnableOption "MongoDB Community Edition document database";
    
    port = mkOption {
      type = types.port;
      default = 27017;
      description = "Port on which MongoDB will listen";
    };
    
    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Interface on which MongoDB will listen";
    };
    
    enableAuth = mkOption {
      type = types.bool;
      default = false;
      description = "Enable MongoDB authentication";
    };
    
    databases = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "myapp" "development" ];
      description = "List of databases to create on startup";
    };
    
    users = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Username";
          };
          passwordFile = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Path to file containing the password";
          };
          roles = mkOption {
            type = types.listOf types.str;
            default = [ "readWrite" ];
            description = "List of roles for this user";
          };
          database = mkOption {
            type = types.str;
            default = "admin";
            description = "Authentication database for this user";
          };
        };
      });
      default = [];
      description = "List of MongoDB users to create";
    };
    
    storageEngine = mkOption {
      type = types.enum [ "wiredTiger" "inMemory" ];
      default = "wiredTiger";
      description = "MongoDB storage engine";
    };
    
    journaling = mkOption {
      type = types.bool;
      default = true;
      description = "Enable MongoDB journaling";
    };
    
    logLevel = mkOption {
      type = types.enum [ "quiet" "normal" "verbose" ];
      default = "normal";
      description = "MongoDB log verbosity level";
    };
    
    maxConnections = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      example = 1000;
      description = "Maximum number of simultaneous connections";
    };
    
    cacheSizeGB = mkOption {
      type = types.nullOr types.ints.positive;
      default = null;
      example = 2;
      description = "WiredTiger cache size in GB (default: 50% of RAM - 1GB)";
    };
    
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall port for MongoDB (only enable for external access)";
    };
    
    replicaSetName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Name of replica set (enables replica set mode)";
    };
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Additional MongoDB configuration in YAML format";
    };
    
    mongoExpress = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Mongo Express web-based MongoDB admin interface";
      };
      
      port = mkOption {
        type = types.port;
        default = 8081;
        description = "Port for Mongo Express web interface";
      };
      
      host = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Host for Mongo Express web interface";
      };
      
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open firewall for Mongo Express (only enable for external access)";
      };
      
      basicAuth = {
        username = mkOption {
          type = types.str;
          default = "admin";
          description = "Basic auth username for Mongo Express";
        };
        
        passwordFile = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Path to file containing basic auth password";
        };
      };
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    assertions = [
      {
        assertion = dependenciesValid;
        message = "MaxOS MongoDB CE wrapper requires user module to be enabled";
      }
      {
        assertion = cfg.bind != "0.0.0.0" || cfg.openFirewall;
        message = "MongoDB binding to all interfaces (0.0.0.0) requires openFirewall to be explicitly enabled";
      }
      {
        assertion = !cfg.enableAuth || (length cfg.users > 0);
        message = "MongoDB authentication enabled but no users configured";
      }
    ];

    # Use standard NixOS MongoDB service with MaxOS enhancements
    services.mongodb = {
      enable = true;
      package = pkgs.mongodb-ce;
    };
    
    # Create MongoDB configuration file with our custom settings
    environment.etc."mongod.conf".text = ''
      # Storage configuration
      storage:
        engine: ${cfg.storageEngine}
        ${optionalString cfg.journaling "journal:\n    enabled: true"}
        ${optionalString (cfg.storageEngine == "wiredTiger" && cfg.cacheSizeGB != null) ''
        wiredTiger:
          engineConfig:
            cacheSizeGB: ${toString cfg.cacheSizeGB}
        ''}
      
      # Network configuration
      net:
        port: ${toString cfg.port}
        bindIp: ${cfg.bind}
        ${optionalString (cfg.maxConnections != null) "maxIncomingConnections: ${toString cfg.maxConnections}"}
      
      # Security configuration
      ${optionalString cfg.enableAuth ''
      security:
        authorization: enabled
      ''}
      
      # Replication configuration
      ${optionalString (cfg.replicaSetName != null) ''
      replication:
        replSetName: ${cfg.replicaSetName}
      ''}
      
      # Logging configuration
      systemLog:
        verbosity: ${if cfg.logLevel == "quiet" then "0" else if cfg.logLevel == "verbose" then "2" else "1"}
        destination: syslog
      
      # Additional configuration
      ${cfg.extraConfig}
    '';
    
    # Override the systemd service to use our config file
    systemd.services.mongodb = {
      serviceConfig = {
        ExecStart = lib.mkForce "${pkgs.mongodb-ce}/bin/mongod --config /etc/mongod.conf";
      };
    };
    
    # Create initialization script for databases and users
    systemd.services.mongodb-init = mkIf (cfg.databases != [] || cfg.users != []) {
      description = "Initialize MongoDB databases and users";
      after = [ "mongodb.service" ];
      wantedBy = [ "multi-user.target" ];
      
      script = ''
        # Wait for MongoDB to be ready
        until ${pkgs.mongodb-ce}/bin/mongosh --eval "db.adminCommand('ismaster')" >/dev/null 2>&1; do
          echo "Waiting for MongoDB to be ready..."
          sleep 2
        done
        
        # Create databases
        ${concatMapStringsSep "\n" (db: ''
          ${pkgs.mongodb-ce}/bin/mongosh --eval "use ${db}; db.init.insertOne({initialized: true});"
        '') cfg.databases}
        
        # Create users
        ${concatMapStringsSep "\n" (user: ''
          ${pkgs.mongodb-ce}/bin/mongosh --eval "
            use ${user.database};
            db.createUser({
              user: '${user.name}',
              pwd: '${if user.passwordFile != null then "$(cat ${user.passwordFile})" else ""}',
              roles: [${concatMapStringsSep ", " (role: "'${role}'") user.roles}]
            });
          "
        '') cfg.users}
      '';
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
    
    # MaxOS-specific enhancements
    environment.systemPackages = with pkgs; [
      mongodb-tools  # mongodump, mongorestore, mongoexport, etc.
      # Note: MongoDB Compass GUI not available in nixpkgs, install manually if needed
    ];
    
    # Note: Mongo Express web interface is not available in nixpkgs
    # Display warning if user tries to enable it
    warnings = lib.optionals cfg.mongoExpress.enable [
      "Mongo Express is not available in nixpkgs. The web interface is disabled. You can install it manually with: npm install -g mongo-express"
    ];

    # Configure firewall if external access is needed
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
    
    # Ensure MongoDB starts after network is ready
    systemd.services.mongodb = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };
    
    # Add useful environment variables
    environment.variables = {
      MONGODB_URL = "mongodb://${cfg.bind}:${toString cfg.port}";
    };
  };
}