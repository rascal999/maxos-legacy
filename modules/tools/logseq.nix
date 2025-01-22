{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.tools.logseq;
in {
  options.modules.tools.logseq = {
    enable = mkEnableOption "logseq";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.logseq ];

    # Configure Logseq to open specific graph by default
    xdg.configFile."logseq/config/config.edn".text = ''
      {:preferred-format :markdown
       :start-with-home-page? false
       :default-graph "/home/user/share/Data/logseq"}
    '';
  };
}
