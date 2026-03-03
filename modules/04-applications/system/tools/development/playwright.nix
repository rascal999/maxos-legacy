{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.playwright;
  # Extract browser revisions from playwright-driver to construct exact executable paths
  browsers = (builtins.fromJSON (builtins.readFile "${pkgs.playwright-driver}/browsers.json")).browsers;
  firefox-rev = (builtins.head (builtins.filter (x: x.name == "firefox") browsers)).revision;
in {
  options.maxos.tools.playwright = {
    enable = mkEnableOption "Playwright CLI and browsers";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      playwright-driver.browsers
      playwright-test
    ];

    environment.variables = {
      PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
      PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
      # NixOS specific fixes for Playwright browsers
      PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
      # Override platform to ensure compatibility with pre-compiled browsers
      PLAYWRIGHT_HOST_PLATFORM_OVERRIDE = "ubuntu-24.04";
      # Ensure Node can find system-wide Playwright modules
      NODE_PATH = "${pkgs.playwright-test}/lib/node_modules";
      # Explicitly point to the Firefox executable in the Nix store
      PLAYWRIGHT_LAUNCH_OPTIONS_EXECUTABLE_PATH = "${pkgs.playwright-driver.browsers}/firefox-${firefox-rev}/firefox/firefox";
    };
  };
}
