{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    i3status-rust
  ];

  # Configure i3status-rust
  programs.i3status-rust = {
    enable = true;
    bars = {
      default = {
        theme = "nord-dark";
        icons = "material-nf";
        settings = {
          theme = {
            overrides = {
              separator = "";
              separator_fg = "auto";
              separator_bg = "auto";
              idle_bg = "#000000";
              info_bg = "#2e3f54";
              good_bg = "#000000";
              warning_bg = "#755f2d";
              critical_bg = "#542a2e";
            };
          };
        };
        blocks = [
          {
            block = "custom";
            command = "${pkgs.writeShellScriptBin "redshift-brightness" (builtins.readFile ../../desktop/redshift-brightness.sh)}/bin/redshift-brightness get";
            on_click = "";
            on_click_right = "";
            on_scroll_up = "${pkgs.writeShellScriptBin "redshift-brightness" (builtins.readFile ../../desktop/redshift-brightness.sh)}/bin/redshift-brightness up";
            on_scroll_down = "${pkgs.writeShellScriptBin "redshift-brightness" (builtins.readFile ../../desktop/redshift-brightness.sh)}/bin/redshift-brightness down";
            interval = 1;
            format = " 󰃟 $text ";
          }
          {
            block = "sound";
            format = " $icon {$volume|} ";
          }
          {
            block = "net";
            format = " $icon {$signal_strength $ssid|Wired} ";
            format_alt = " $icon {$signal_strength $ssid|Wired} $ip ";
          }
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
            alert_unit = "GB";
            interval = 20;
            warning = 20.0;
            alert = 10.0;
            format = " $icon $available ";
          }
          {
            block = "memory";
            format = " $icon $mem_used_percents ";
            format_alt = " $icon_swap $swap_used_percents ";
          }
          {
            block = "load";
            interval = 1;
            format = " $icon $1m.eng(w:4) $15m.eng(w:4) ";
          }
          {
            block = "cpu";
            interval = 1;
            format = " $icon $frequency.eng(w:4) $utilization.eng(w:3) ";
          }
          {
            block = "battery";
            format = " $icon $percentage {$time |}";
            device = "BAT1";
            missing_format = "";
          }
          {
            block = "time";
            interval = 5;
            format = " $icon $timestamp.datetime(f:'%V %m/%d %R') ";
          }
        ];
      };
    };
  };
}
