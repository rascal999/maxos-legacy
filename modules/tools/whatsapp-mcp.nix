{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.tools.whatsapp-mcp;
in {
  options.modules.tools.whatsapp-mcp = {
    enable = mkEnableOption "WhatsApp MCP service";
    
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/whatsapp-mcp";
      description = "Directory to store WhatsApp data";
    };
    
    user = mkOption {
      type = types.str;
      default = "whatsapp-mcp";
      description = "User to run the WhatsApp MCP service";
    };
    
    group = mkOption {
      type = types.str;
      default = "whatsapp-mcp";
      description = "Group to run the WhatsApp MCP service";
    };
  };

  config = mkIf cfg.enable {
    # Only create user and group if not using an existing user
    users.users = mkIf (cfg.user != "user") {
      ${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
        createHome = true;
        description = "WhatsApp MCP service user";
      };
    };
    
    users.groups = mkIf (cfg.group != "users") {
      ${cfg.group} = {};
    };
    
    # Create data directory if it doesn't exist
    systemd.tmpfiles.rules = mkIf (cfg.user != "user") [
      "d '${cfg.dataDir}' 0750 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.dataDir}/store' 0750 ${cfg.user} ${cfg.group} - -"
    ];
    
    # WhatsApp bridge service
    systemd.services.whatsapp-bridge = {
      description = "WhatsApp Bridge Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "/home/user/git/github/whatsapp-mcp/whatsapp-bridge";
        ExecStart = "${pkgs.go}/bin/go run main.go";
        Restart = "on-failure";
        RestartSec = "5s";
        Environment = "STORE_DIR=/home/user/git/github/whatsapp-mcp/data/store";
        
        # Security hardening (adjusted for user service)
        ProtectSystem = mkIf (cfg.user != "user") "strict";
        ProtectHome = mkIf (cfg.user != "user") "read-only";
        PrivateTmp = mkIf (cfg.user != "user") true;
        NoNewPrivileges = mkIf (cfg.user != "user") true;
        
        # Allow access to the data directory
        ReadWritePaths = mkIf (cfg.user != "user") [ "${cfg.dataDir}" ];
      };
    };
    
    # Install required packages
    environment.systemPackages = with pkgs; [
      go
      python3
      python3Packages.pip
      ffmpeg # Optional but recommended for audio message support
      uv # Python package manager
    ];
    
    # Add the WhatsApp MCP server to the mcp_settings.json
    # This is handled separately in the user's home directory
  };
}