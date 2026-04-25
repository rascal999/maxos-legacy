{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.llama-cpp;
  
  dependenciesValid =
    config.maxos.user.enable or true;
    
  llamaCppPackage = if cfg.cudaSupport then
    pkgs.llama-cpp.override { cudaSupport = true; }
  else
    pkgs.llama-cpp;
    
in {
  options.maxos.tools.llama-cpp = {
    enable = mkEnableOption "llama.cpp - LLM inference in C/C++";
    
    cudaSupport = mkOption {
      type = types.bool;
      default = false;
      description = "Enable CUDA acceleration for NVIDIA GPUs";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = [ llamaCppPackage ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "llama-cpp requires user module to be enabled";
      }
    ];
  };
}
