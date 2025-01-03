{ config, lib, pkgs, ... }:

{
  # Firefox policies configuration
  home.file.".mozilla/firefox/policies/policies.json" = {
    source = ./policies.json;
  };

  # Firefox MIME types
  home.file.".mozilla/firefox/mime.types".source = ./mime.types;

  # Firefox configuration
  programs.firefox = {
    enable = true;

    profiles =
      let defaultSettings = {
        "widget.disable-workspace-management" = true;
        "accessibility.force_disabled" = 1;
        "app.normandy.api_url" = "";
        "app.normandy.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "app.update.auto" = false;

        "beacon.enabled" = false;
        "breakpad.reportURL" = "";
        "browser.aboutConfig.showWarning" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        "browser.crashReports.unsubmittedCheck.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.newtabpage.activity-stream.default.sites" = "";
        "browser.newtabpage.activity-stream.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.places.speculativeConnect.enabled" = false;
        "browser.privatebrowsing.forceMediaMemoryCache" = true;
        "browser.region.network.url" = "";
        "browser.region.update.enabled" = false;
        "browser.safebrowsing.downloads.remote.enabled" = false;
        "browser.search.openintab" = true;
        "browser.send_pings" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.tabs.crashReporting.sendReport" = false;
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.urlbar.speculativeConnect.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.xul.error_pages.expert_bad_cert" = true;

        "captivedetect.canonicalURL" = "";

        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "device.sensors.enabled" = false;
        "devtools.chrome.enabled" = true;
        "devtools.debugger.remote-enabled" = false;
        "devtools.inspector.showUserAgentStyles" = true;
        "devtools.theme" = "dark";

        "dom.disable_window_move_resize" = true;

        "extensions.autoDisableScopes" = "0";
        "extensions.getAddons.showPane" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.pocket.enable" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "experiments.enabled" = false;
        "experiments.supported" = false;

        "geo.provider.use_gpsd" = false;
        "layout.css.devPixelsPerPx" = "1.5";
        "media.memory_cache_max_size" = 65536;

        "network.captive-portal-service.enabled" = false;
        "network.connectivity-service.enabled" = false;
        "network.cookie.cookieBehavior" = 5;
        "network.dns.disablePrefetch" = true;
        "network.http.speculative-parallel-limit" = 0;
        "network.predictor.enabled" = false;
        "network.predictor.enable-prefetch" = false;
        "network.prefetch-next" = false;
        "network.proxy.socks_remote_dns" = true;

        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.trackingprotection.pbmode.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;

        "security.dialog_enable_delay" = 300;
        "security.ssl.require_safe_negotiation" = true;
        "services.sync.engine.addons" = false;
        "services.sync.engine.passwords" = false;
        "services.sync.engine.prefs" = false;
        "services.sync.engineStatusChanged.addons" = true;
        "signon.autofillForms" = false;
        "signon.formlessCapture.enabled" = false;
        "signon.rememberSignons" = false;

        "toolkit.coverage.endpoint.base" = "";
        "toolkit.coverage.opt-out" = true;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.coverage.opt-out" = true;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.server" = "data:";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;

        "ui.systemUsesDarkTheme" = 1;
      };
    in {
      default = {
        id = 0;
        name = "Default";
        isDefault = true;
        settings = defaultSettings;

        userChrome = builtins.readFile ./css/userChrome.css;
        userContent = builtins.readFile ./css/userContent.css;
      };

      burp = {
        id = 1;
        name = "Burp";
        isDefault = false;
        settings = defaultSettings;

        userChrome = builtins.readFile ./css/userChromeBurp.css;
        userContent = builtins.readFile ./css/userContent.css;
      };

      selenium = {
        id = 2;
        name = "Selenium";
        isDefault = false;
        settings = defaultSettings;

        userChrome = builtins.readFile ./css/userChrome.css;
        userContent = builtins.readFile ./css/userContent.css;
      };
    };
  };
}
