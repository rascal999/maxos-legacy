# Module validation integration for MaxOS
{ config, lib, pkgs, ... }:

let
  moduleValidation = import ../../lib/module-validation.nix { inherit lib; };
  
  cfg = config.maxos.validation;
  
in {
  options.maxos.validation = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable module validation checks";
    };
    
    strictMode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable strict validation that fails builds on invalid modules";
    };
    
    generateReport = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Generate validation report during build";
    };
  };

  config = lib.mkIf cfg.enable {
    # Add module validation assertions
    assertions = if cfg.strictMode then
      moduleValidation.createModuleAssertions config ++
      [
        # User configuration validation
        {
          assertion = config.maxos.user.name != "";
          message = "maxos.user.name cannot be empty";
        }
        {
          assertion = config.maxos.user.homeDirectory != "";
          message = "maxos.user.homeDirectory must be specified";
        }
        {
          assertion = lib.hasPrefix "/home/" config.maxos.user.homeDirectory;
          message = "maxos.user.homeDirectory should start with /home/";
        }
        
        # Hostname validation
        {
          assertion = config.networking.hostName != "";
          message = "networking.hostName cannot be empty";
        }
        {
          assertion = lib.stringLength config.networking.hostName <= 63;
          message = "networking.hostName must be 63 characters or less";
        }
        {
          assertion = !(lib.hasInfix "." config.networking.hostName);
          message = "networking.hostName should not contain dots";
        }
        
        # Profile validation
        {
          assertion = 
            let enabledProfiles = builtins.length (builtins.filter (x: x) [
              (config.maxos.profiles.fullStackDeveloper or false)
              (config.maxos.profiles.securityAnalyst or false)  
              (config.maxos.profiles.dataScientist or false)
              (config.maxos.profiles.homeServer or false)
              (config.maxos.profiles.minimal or false)
            ]);
            in enabledProfiles <= 1;
          message = "Only one MaxOS profile can be enabled at a time";
        }
        
        # Hardware validation
        {
          assertion = 
            let hardwareTypes = builtins.length (builtins.filter (x: x) [
              (config.maxos.hardware.laptop.enable or false)
              (config.maxos.hardware.desktop.enable or false)
              (config.maxos.hardware.server.enable or false)
            ]);
            in hardwareTypes <= 1;
          message = "Only one hardware type can be enabled at a time";
        }
        
        # Graphics validation
        {
          assertion = !(config.maxos.hardware.desktop.graphics.nvidia or false && 
                       config.maxos.hardware.desktop.graphics.amd or false);
          message = "Cannot enable both NVIDIA and AMD graphics simultaneously";
        }
      ]
    else [];
    
    # Add warnings for common module issues
    warnings = let
      enabledTools = lib.filterAttrs (_: toolConfig: 
        toolConfig ? enable && toolConfig.enable
      ) (config.modules.tools or {});
      
      # Check for tools that depend on each other
      dockerEnabled = (config.modules.tools.docker.enable or false);
      kindEnabled = (config.modules.tools.kind.enable or false);
      
      dependencyWarnings = [
        (lib.optionalString (kindEnabled && !dockerEnabled)
          "Kind is enabled but Docker is not - Kind requires Docker to function properly")
        
        (lib.optionalString (config.maxos.hardware.laptop.enable or false && 
                            !(config.maxos.hardware.laptop.powerManagement.enable or true))
          "Power management is disabled on laptop - this may impact battery life")
        
        (lib.optionalString (config.maxos.hardware.desktop.enable or false && 
                            (config.maxos.hardware.desktop.performance.governor or "performance") == "powersave")
          "Desktop is using powersave governor - consider 'performance' for better responsiveness")
        
        (lib.optionalString (config.modules.toolBundles.gaming.enable or false && 
                            !(config.maxos.hardware.desktop.graphics.nvidia or false || 
                              config.maxos.hardware.desktop.graphics.amd or false))
          "Gaming bundle is enabled but no dedicated GPU is configured")
        
        (lib.optionalString (config.modules.tools.steam.enable or false && 
                            config.maxos.hardware.server.enable or false)
          "Steam gaming is not suitable for server configurations")
      ];
      
    in builtins.filter (w: w != "") dependencyWarnings;
    
    # Generate validation report if requested
    system.build.moduleValidationReport = lib.mkIf cfg.generateReport (
      let
        validation = moduleValidation.validateAllModules ../tools;
        report = moduleValidation.generateValidationReport validation;
      in
      pkgs.writeText "module-validation-report" (
        report.summary + "\n\n" +
        "Valid modules: " + (lib.concatStringsSep ", " report.validModules) + "\n\n" +
        report.invalidModules
      )
    );
  };
}