{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.logseq;
  # In home-manager context, use home.homeDirectory
  userConfig = {
    homeDirectory = config.home.homeDirectory;
  };
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true; # Logseq has no hard dependencies
  
in {
  options.maxos.tools.logseq = {
    enable = mkEnableOption "Logseq knowledge management application";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    home.packages = [ pkgs.logseq ];

    # Configure Logseq settings
    xdg.configFile."logseq/config.edn".text = ''
      {:preferred-format :markdown
       :start-with-home-page? false
       :default-home {:page "Contents"}
       :feature/enable-journals? true
       :feature/enable-whiteboards? true
       :feature/enable-flashcards? true
       :default-graphs {:primary "${userConfig.homeDirectory}/share/Data/logseq"}
       :feature/enable-block-timestamps? false
       :feature/enable-timetracking? false
       :feature/enable-git-auto-push? false
       :graph/settings {:journal? true}
       :ui/auto-open-last-graph? true}
    '';
    
    assertions = [
      {
        assertion = dependenciesValid;
        message = "Logseq knowledge management application has no hard dependencies";
      }
    ];
  };
}
