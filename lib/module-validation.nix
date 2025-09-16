# Module Validation System for MaxOS
{ lib }:

let
  inherit (lib) mkOption mkEnableOption types hasAttrByPath attrByPath;
  
  # Standard module structure validation
  validateModuleStructure = modulePath: moduleName:
    let
      module = import modulePath;
      
      # Basic checks
      isFunction = builtins.isFunction module;
      
      # If it's a function, try to evaluate it with dummy args to check structure
      dummyArgs = {
        config = {};
        lib = lib;
        pkgs = {};
        osConfig = {};
      };
      
      evaluatedModule = if isFunction then (module dummyArgs) else module;
      
      # Check for required attributes
      hasOptions = evaluatedModule ? options;
      hasConfig = evaluatedModule ? config;
      
      # Check if it follows MaxOS tool naming convention
      expectedOptionPath = [ "modules" "tools" moduleName ];
      hasCorrectOptionPath = if hasOptions then
        hasAttrByPath expectedOptionPath evaluatedModule.options
      else false;
      
      # Check if enable option exists
      hasEnableOption = if hasCorrectOptionPath then
        let toolOptions = attrByPath expectedOptionPath {} evaluatedModule.options;
        in toolOptions ? enable
      else false;
      
    in {
      moduleName = moduleName;
      modulePath = toString modulePath;
      checks = {
        isFunction = isFunction;
        hasOptions = hasOptions;
        hasConfig = hasConfig;
        hasCorrectOptionPath = hasCorrectOptionPath;
        hasEnableOption = hasEnableOption;
      };
      valid = isFunction && hasOptions && hasConfig && hasCorrectOptionPath && hasEnableOption;
      errors = builtins.filter (x: x != null) [
        (if !isFunction then "Module is not a function" else null)
        (if !hasOptions then "Module missing 'options' attribute" else null)
        (if !hasConfig then "Module missing 'config' attribute" else null)
        (if !hasCorrectOptionPath then "Module doesn't define options.modules.tools.${moduleName}" else null)
        (if !hasEnableOption then "Module missing 'enable' option" else null)
      ];
    };

  # Validate all modules in a directory
  validateAllModules = modulesDir:
    let
      moduleDiscovery = import ./module-discovery.nix { inherit lib; };
      allModules = moduleDiscovery.discoverNixFiles modulesDir;
      
      validationResults = lib.mapAttrs (name: path:
        validateModuleStructure path name
      ) allModules;
      
      validModules = lib.filterAttrs (_: result: result.valid) validationResults;
      invalidModules = lib.filterAttrs (_: result: !result.valid) validationResults;
      
    in {
      all = validationResults;
      valid = validModules;
      invalid = invalidModules;
      summary = {
        total = lib.length (lib.attrNames validationResults);
        valid = lib.length (lib.attrNames validModules);
        invalid = lib.length (lib.attrNames invalidModules);
      };
    };

  # Generate validation report
  generateValidationReport = validation:
    let
      validNames = lib.attrNames validation.valid;
      invalidNames = lib.attrNames validation.invalid;
      
      invalidDetails = lib.mapAttrsToList (name: result: {
        inherit name;
        inherit (result) errors;
      }) validation.invalid;
      
    in {
      summary = "Module Validation Report:\n" +
                "  Total modules: ${toString validation.summary.total}\n" +
                "  Valid: ${toString validation.summary.valid}\n" +
                "  Invalid: ${toString validation.summary.invalid}\n";
      
      validModules = validNames;
      
      invalidModules = if invalidNames != [] then
        "Invalid modules:\n" + 
        (lib.concatStringsSep "\n" (map (detail: 
          "  ${detail.name}:\n" + 
          (lib.concatStringsSep "\n" (map (error: "    - ${error}") detail.errors))
        ) invalidDetails))
      else "All modules are valid!";
    };

  # Runtime assertion helper for modules
  assertValidModule = moduleName: config:
    let
      toolConfig = config.modules.tools.${moduleName} or {};
      hasEnable = toolConfig ? enable;
      
      assertion = {
        assertion = hasEnable;
        message = "Module ${moduleName} is missing required 'enable' option";
      };
    in assertion;

  # Create validation assertions for all enabled modules
  createModuleAssertions = config:
    let
      enabledModules = lib.filterAttrs (_: toolConfig: 
        toolConfig ? enable && toolConfig.enable
      ) (config.modules.tools or {});
      
      assertions = lib.mapAttrsToList (name: _: 
        assertValidModule name config
      ) enabledModules;
      
    in assertions;

in {
  inherit validateModuleStructure validateAllModules generateValidationReport;
  inherit assertValidModule createModuleAssertions;
}