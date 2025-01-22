{ config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.tools.logseq;
in {
  options.modules.tools.logseq = {
    enable = mkEnableOption "logseq";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.logseq ];

    # Configure Logseq settings
    xdg.configFile."logseq/config.edn".text = ''
      {:preferred-format :markdown
       :start-with-home-page? false
       :default-home {:page "Contents"}
       :feature/enable-journals? true
       :feature/enable-whiteboards? true
       :feature/enable-flashcards? true
       :default-graphs {:primary "/home/user/share/Data/logseq"}
       :feature/enable-block-timestamps? false
       :feature/enable-timetracking? false
       :feature/enable-git-auto-push? false
       :graph/settings {:journal? true}
       :ui/auto-open-last-graph? true}
    '';
  };
}
