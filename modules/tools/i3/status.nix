{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    i3status-rust
  ];

  # Configure i3status-rust
  programs.i3status-rust = {
    enable = true;
    theme = "nord-dark";
    icons = "material-nf";
    theme_overrides = {
      separator = "";
      separator_fg = "auto";
      separator_bg = "auto";
    };
    bars = {
      default = {
        blocks = [
          {
            block = "sound";
            format = " $icon {$volume|} ";
          }
          {
            block = "net";
            format = " $icon {$signal_strength $ssid $frequency|Wired} ";
            format_alt = " $icon {$signal_strength $ssid $frequency|Wired} $ip ";
          }
          {
            block = "cpu";
            interval = 1;
            format = " $icon $frequency.eng(w:4) $utilization.eng(w:3) ";
          }
          {
            block = "load";
            interval = 1;
            format = " $icon $1m.eng(w:4) $5m.eng(w:4) $15m.eng(w:4) ";
          }
          {
            block = "memory";
            format = " $icon $mem_used_percents ";
            format_alt = " $icon_swap $swap_used_percents ";
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
            block = "time";
            interval = 5;
            format = " $icon $timestamp.datetime(f:'%V %b %d %R %Z') ";
          }
          {
            block = "battery";
            format = " $icon $percentage {$time |}";
            device = "BAT1";
            missing_format = "";
          }
        ];
      };
    };
  };
}
