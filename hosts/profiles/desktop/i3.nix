{ config, pkgs, lib, ... }:

{
  # i3 window manager configuration
  services.xserver = {
    enable = true;
    
    # Configure i3 as the window manager
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3;
      extraPackages = with pkgs; [
        i3status       # Status bar
        i3lock        # Screen locker
        i3blocks      # Status bar blocks
      ];
    };
    
    # Set i3 as default
    displayManager.lightdm.enable = true;
  };

  # Set i3 as default session
  services.displayManager.defaultSession = lib.mkForce "none+i3";

  # i3status-rust configuration for all users
  home-manager.users.user = { pkgs, ... }: {
    # i3status-rust configuration
    xdg.configFile."i3status-rust/config.toml".text = ''
      [theme]
      theme = "solarized-dark"
      [icons]
      icons = "awesome6"

      [[block]]
      block = "sound"
      step_width = 3
      [block.mappings]
      "alsa_output.usb-Harman_Multimedia_JBL_Pebbles_1.0.0-00.analog-stereo" = "🔈"
      "alsa_output.pci-0000_00_1b.0.analog-stereo" = "🎧"

      [[block]]
      block = "music"
      format = " $icon {$combo.str(max_w:40) |}"
      [[block.click]]
      button = "left"
      action = "play_pause"
      [[block.click]]
      button = "right"
      action = "next"

      [[block]]
      block = "net"
      device = "enp.*"
      format = "$speed_down.eng(prefix:M) ↓ $speed_up.eng(prefix:M) ↑ {$signal_strength $ssid $frequency|} $ip "
      [[block.click]]
      button = "left"
      cmd = "/run/current-system/sw/bin/urxvt -e nmtui"

      [[block]]
      block = "external_ip"
      format = "$country_flag $asn '$org' $ip"
      with_network_manager = true
      interval = 300

      [[block]]
      block = "hueshift"
      hue_shifter = "gammastep"
      step = 100
      click_temp = 1900

      [[block]]
      block = "load"
      format = "$icon $1m.eng(w:4) $5m.eng(w:4) $15m.eng(w:4)"
      interval = 1

      [[block]]
      block = "memory"
      format = " $icon $mem_total_used_percents.eng(w:2)"
      format_alt = " $icon_swap $swap_used_percents.eng(w:2)"

      [[block]]
      block = "disk_space"
      path = "/"
      info_type = "available"
      interval = 20

      [[block]]
      block = "battery"
      interval = 10
      format = "$percentage $time"
      missing_format = ""

      [[block]]
      block = "tea_timer"
      format = " $icon {$hours:$minutes:$seconds |}"
      done_cmd = "notify-send 'Timer Finished'"
      increment = 300

      [[block]]
      block = "time"
      interval = 20
      format = "$timestamp.datetime(f:'%V %m/%d %R')"
    '';

    # i3 configuration
    xsession.windowManager.i3 = {
      enable = true;

      extraConfig = ''
        default_border pixel 1
        for_window [class=".*KeePassXC.*"] move to workspace "pw"
        for_window [class=".*Logseq.*"] move to workspace "2:ls"
        for_window [class=".*Remmina.*"] move to workspace rdp
        for_window [class=".*VirtualBox Machine.*"] move to workspace "vm"
        for_window [class=".*VirtualBox Manager.*"] move to workspace "vm"
        for_window [class=".*Slack.*"] move to workspace "ytm"
        for_window [class=".*vlc.*"] move to workspace "vid"
        for_window [class=".*Chromium.*"] move to workspace "chr"
        for_window [class=".*Wireshark.*"] move to workspace "fin"
        no_focus [class="org.remmina.Remmina"]
        focus_on_window_activation none
      '';

      config = {
        modifier = "Mod1";
        workspaceAutoBackAndForth = true;

        fonts = {
          names = ["DejaVu Sans Mono, FontAwesome 6"];
          style = "Semi-Condensed";
          size = 11.0;
        };

        window.hideEdgeBorders = "both";

        bars = [
          {
            trayOutput = "primary";
            fonts = {
              names = ["DejaVu Sans Mono, FontAwesome 14"];
              style = "Semi-Condensed";
              size = 16.0;
            };

            position = "bottom";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs $HOME/.config/i3status-rust/config.toml";
            colors = {
              separator = "#666666";
              statusline = "#dddddd";
              focusedWorkspace = {
                background = "#0088CC";
                border = "#0088CC";
                text = "#ffffff";
              };
              activeWorkspace = {
                background = "#333333";
                border = "#333333";
                text = "#ffffff";
              };
              inactiveWorkspace = {
                background = "#333333";
                border = "#333333";
                text = "#888888";
              };
              urgentWorkspace = {
                background = "#2f343a";
                border = "#900000";
                text = "#ffffff";
              };
            };
          }
        ];

        keybindings = let mod = "Mod1"; in {
          "${mod}+Return" = "exec ${pkgs.rofi}/bin/rofi -show run";
          "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
          "${mod}+Shift+q" = "kill";
          "${mod}+f" = "fullscreen";
          "${mod}+Shift+c" = "reload";
          "${mod}+Shift+r" = "restart";
          
          # Focus
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          # Move
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          # Workspaces
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace 2:ls";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          # Move to workspace
          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace 2:ls";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";
        };
      };
    };
  };
}
