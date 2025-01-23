{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.tools.llm.chatbox;
  chatbox = pkgs.callPackage ./chatbox-pkg.nix {};
in
{
  options.modules.tools.llm.chatbox = {
    enable = mkEnableOption "chatbox";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ chatbox ];
  };
}
