{ config, pkgs, lib, ... }:

{
  options.services.rocketchat = {
    enable = lib.mkEnableOption "Rocket.Chat server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 3200;
      description = "Port to expose Rocket.Chat on (default: 3200)";
    };
  };

  config = lib.mkIf config.services.rocketchat.enable {
    # Ensure docker is enabled
    virtualisation.docker.enable = true;

    # Create docker compose service
    systemd.services.rocketchat = {
      description = "Rocket.Chat server";
      after = [ "docker.service" "network.target" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        RuntimeDirectory = "rocketchat";
        RuntimeDirectoryMode = "0755";
        StateDirectory = "rocketchat";
        StateDirectoryMode = "0755";
        WorkingDirectory = "/var/lib/rocketchat";
        User = "root";
        Group = "root";
        StandardOutput = "journal";
        StandardError = "journal";
        ExecStartPre = let
          cleanup = pkgs.writeScript "cleanup-rocketchat" ''
            #!${pkgs.runtimeShell}
            echo "Stopping and removing existing containers..."
            ${pkgs.docker}/bin/docker stop rocketchat mongodb || true
            ${pkgs.docker}/bin/docker rm rocketchat mongodb || true
            echo "Cleaning up data directory..."
            rm -rf /var/lib/rocketchat/data/*
            echo "Creating required directories..."
            mkdir -p /var/lib/rocketchat/data/{db,dumps,uploads}
            chmod -R 755 /var/lib/rocketchat
          '';
        in [ cleanup ];
        ExecStart = let
          composeFile = pkgs.writeText "docker-compose.yml" ''
            name: rocketchat
            services:
              rocketchat:
                container_name: rocketchat
                image: registry.rocket.chat/rocketchat/rocket.chat:latest
                restart: unless-stopped
                volumes:
                  - /var/lib/rocketchat/data/uploads:/app/uploads
                environment:
                  MONGO_URL: mongodb://mongodb:27017/rocketchat?replicaSet=rs0
                  MONGO_OPLOG_URL: mongodb://mongodb:27017/local?replicaSet=rs0
                  ROOT_URL: http://localhost:${toString config.services.rocketchat.port}
                  PORT: "3000"
                depends_on:
                  - mongodb
                ports:
                  - "${toString config.services.rocketchat.port}:3000"
                healthcheck:
                  test: ["CMD", "curl", "-f", "http://localhost:3000"]
                  interval: 30s
                  timeout: 10s
                  retries: 3

              mongodb:
                container_name: mongodb
                image: mongo:6.0
                restart: unless-stopped
                volumes:
                  - /var/lib/rocketchat/data/db:/data/db
                  - /var/lib/rocketchat/data/dumps:/dumps
                command: mongod --oplogSize 128 --replSet rs0
                healthcheck:
                  test: ["CMD", "mongosh", "--eval", "db.runCommand({ ping: 1 }).ok"]
                  interval: 30s
                  timeout: 10s
                  retries: 3
          '';
          startScript = pkgs.writeScript "start-rocketchat" ''
            #!${pkgs.runtimeShell}
            set -e
            
            echo "Starting services..."
            ${pkgs.docker-compose}/bin/docker-compose -f ${composeFile} up -d
            
            echo "Waiting for MongoDB to be ready..."
            for i in {1..30}; do
              if ${pkgs.docker}/bin/docker exec mongodb mongosh --eval "db.runCommand({ ping: 1 }).ok" >/dev/null 2>&1; then
                echo "MongoDB is ready"
                break
              fi
              echo "Waiting for MongoDB... $i/30"
              sleep 2
            done
            
            echo "Initializing replica set..."
            ${pkgs.docker}/bin/docker exec mongodb mongosh --eval '
              try {
                rs.status();
              } catch (err) {
                if (err.codeName === "NotYetInitialized") {
                  rs.initiate();
                  print("Replica set initialized");
                } else {
                  print("Error checking replica set status:", err);
                  quit(1);
                }
              }
            '
          '';
        in startScript;
        ExecStop = pkgs.writeScript "stop-rocketchat" ''
          #!${pkgs.runtimeShell}
          echo "Stopping services..."
          cd /var/lib/rocketchat
          ${pkgs.docker-compose}/bin/docker-compose down -v
        '';
      };
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ config.services.rocketchat.port ];

    # Ensure docker-compose is available
    environment.systemPackages = [ pkgs.docker-compose ];
  };
}
