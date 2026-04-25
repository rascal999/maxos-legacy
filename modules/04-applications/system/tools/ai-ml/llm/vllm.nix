{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.vllm;
  
  dependenciesValid =
    config.maxos.user.enable or true;
    
  vllmPackage = if cfg.cudaSupport then
    pkgs.vllm.override { cudaSupport = true; }
  else
    pkgs.vllm;
    
in {
  options.maxos.tools.vllm = {
    enable = mkEnableOption "vLLM - high-throughput LLM inference engine";
    
    cudaSupport = mkOption {
      type = types.bool;
      default = false;
      description = "Enable CUDA acceleration for NVIDIA GPUs";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    environment.systemPackages = [ vllmPackage ];
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "vllm requires user module to be enabled";
      }
    ];
  };
}
