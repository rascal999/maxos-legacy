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
        blocks = [
          {
            block = "sound";
            format = " $icon {$volume|} ";
          }
          {
            block = "cpu";
            interval = 1;
            format = " $icon $utilization ";
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
            block = "net";
            format = " $icon {$signal_strength $ssid $frequency|Wired} ";
            format_alt = " $icon {$signal_strength $ssid $frequency|Wired} $ip ";
          }
          {
            block = "battery";
            format = " $icon $percentage {$time |}";
            device = "BAT0";
            missing_format = "";
          }
          {
            block = "time";
            interval = 5;
            format = " $icon $timestamp.datetime(f:'%V %b %d %R') ";
          }
        ];
      };
    };
  };
}
