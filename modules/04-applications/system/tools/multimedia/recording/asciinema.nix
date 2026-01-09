{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.asciinema;
in {
  options.maxos.tools.asciinema = {
    enable = mkEnableOption "asciinema terminal recorder and agg (asciinema gif generator)";
    
    package = mkOption {
      type = types.package;
      default = pkgs.asciinema;
      description = "The asciinema package to use.";
    };

    enableAgg = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to install asciinema-agg (gif generator).";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ] ++ optionals cfg.enableAgg [ pkgs.asciinema-agg ];
  };
}