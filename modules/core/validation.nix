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
      moduleValidation.createModuleAssertions config
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