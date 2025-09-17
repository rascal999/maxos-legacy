{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.java;
in {
  options.maxos.tools.java = {
    enable = mkEnableOption "Java development tools";
    
    jdkVersion = mkOption {
      type = types.str;
      default = "jdk";
      description = "JDK package to use (jdk, jdk8, jdk11, jdk17, jdk21, etc.)";
    };
    
    includeMaven = mkOption {
      type = types.bool;
      default = true;
      description = "Include Apache Maven build tool";
    };
    
    includeGradle = mkOption {
      type = types.bool;
      default = true;
      description = "Include Gradle build tool";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # JDK - use the specified version
      (getAttr cfg.jdkVersion pkgs)
    ] ++ optionals cfg.includeMaven [
      maven
    ] ++ optionals cfg.includeGradle [
      gradle
    ];

    # Set JAVA_HOME environment variable
    environment.variables = {
      JAVA_HOME = "${getAttr cfg.jdkVersion pkgs}/lib/openjdk";
    };
  };
}