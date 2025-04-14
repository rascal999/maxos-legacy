{ config, pkgs, lib, ... }:

{
  options.modules.tools.mongodb = {
    enable = lib.mkEnableOption "MongoDB database server";
    compass = {
      enable = lib.mkEnableOption "MongoDB Compass GUI client";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.modules.tools.mongodb.enable {
      # Enable the MongoDB service
      services.mongodb.enable = true;

      # Add MongoDB client tools to system packages
      environment.systemPackages = with pkgs; [
        mongodb-tools  # Includes mongodump, mongorestore, etc.
      ];
    })

    (lib.mkIf config.modules.tools.mongodb.compass.enable {
      # Add MongoDB Compass to system packages
      environment.systemPackages = with pkgs; [
        mongodb-compass  # MongoDB GUI client
      ];
    })
  ];
}