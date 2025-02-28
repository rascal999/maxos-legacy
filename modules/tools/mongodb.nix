{ config, pkgs, lib, ... }:

{
  options.modules.tools.mongodb = {
    enable = lib.mkEnableOption "MongoDB database server";
  };

  config = lib.mkIf config.modules.tools.mongodb.enable {
    # Enable the MongoDB service
    services.mongodb.enable = true;

    # Add MongoDB client tools to system packages
    environment.systemPackages = with pkgs; [
      mongodb-tools  # Includes mongodump, mongorestore, etc.
    ];
  };
}