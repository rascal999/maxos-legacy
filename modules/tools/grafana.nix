{ config, pkgs, lib, ... }:

{
  options.modules.tools.grafana = {
    enable = lib.mkEnableOption "Grafana dashboard and visualization platform";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port to expose Grafana on (default: 3000)";
    };
    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Domain name for Grafana (default: localhost)";
    };
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/user/git/github/monorepo/tools/grafana/data";
      description = "Directory to store Grafana data";
    };
    # MongoDB connection options
    mongodb = {
      enable = lib.mkEnableOption "MongoDB datasource for Grafana";
      url = lib.mkOption {
        type = lib.types.str;
        default = "mongodb://localhost:27017";
        description = "MongoDB connection URL";
      };
      database = lib.mkOption {
        type = lib.types.str;
        default = "metrics";
        description = "MongoDB database name";
      };
      username = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "MongoDB username (optional)";
      };
      password = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "MongoDB password (optional)";
      };
    };
  };

  config = lib.mkIf config.modules.tools.grafana.enable {
    # Create directories for Grafana with proper permissions
    systemd.tmpfiles.rules = [
      "d /home/user/git/github/monorepo/tools/grafana/data 0777 root root - -"
      "d /home/user/git/github/monorepo/tools/grafana/provisioning 0777 root root - -"
      "d /home/user/git/github/monorepo/tools/grafana/provisioning/datasources 0777 root root - -"
      "d /home/user/git/github/monorepo/tools/grafana/provisioning/dashboards 0777 root root - -"
    ];
    
    # No need for activation scripts as docker-compose will handle the volumes
    
    # Create systemd service for Grafana Docker container
    systemd.services.grafana-docker = {
      description = "Grafana Enterprise Docker Container";
      after = [ "system-activation.service" "docker.service" "network.target" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      
      # Make sure the service starts after the activation script has run
      wants = [ "system-activation.service" ];
      
      # Add path dependencies
      path = [ pkgs.docker ];
      
      serviceConfig = {
        # Fix: Use oneshot type with RemainAfterExit=yes
        Type = "oneshot";
        RemainAfterExit = "yes";
        
        # Use a script for more control
        ExecStart = pkgs.writeShellScript "start-grafana-docker" ''
          # Make sure Docker is running
          if ! docker info > /dev/null 2>&1; then
            echo "Docker is not running. Exiting."
            exit 1
          fi
          
          # Change to the Grafana directory
          cd /home/user/git/github/monorepo/tools/grafana
          
          # Make sure directories exist with proper permissions
          mkdir -p data
          chmod 777 data  # Ensure container has full access
          mkdir -p provisioning/dashboards provisioning/datasources
          chmod -R 777 provisioning  # Ensure container has full access
          
          # Run docker-compose with full path
          exec ${pkgs.docker-compose}/bin/docker-compose up -d
        '';
        
        ExecStop = pkgs.writeShellScript "stop-grafana-docker" ''
          cd /home/user/git/github/monorepo/tools/grafana
          exec ${pkgs.docker-compose}/bin/docker-compose down
        '';
        
        # Change from always to on-failure since we're using oneshot
        Restart = "on-failure";
        RestartSec = "10s";
        TimeoutStartSec = "120s";
        
        # Run as root to access Docker
        User = "root";
        Group = "root";
      };
    };

    # Add Docker and related tools to system packages
    environment.systemPackages = with pkgs; [
      docker
      docker-compose
    ];
  };
}