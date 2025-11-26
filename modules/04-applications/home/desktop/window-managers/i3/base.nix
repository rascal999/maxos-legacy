{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.i3;
  
  # Validate dependencies exist before referencing them
  dependenciesValid = true; # i3 has no hard dependencies
  
in {
  imports = [
    ../../../../system/tools/desktop/window-managers/i3/appearance.nix
  ];

  options.maxos.tools.i3 = {
    enable = mkEnableOption "i3 window manager configuration";
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    programs.home-manager.enable = true;

  # GTK theme configuration for dark theme
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Qt theme configuration for consistency
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  # Enable dconf for GTK settings
  dconf.enable = true;

  # Shell aliases
  programs.bash = {
    enable = true;
    shellAliases = {
      gcp = "git status && git add -A && git commit && git push";
    };
  };

  home.packages = with pkgs; [
    i3lock
    dmenu
    gnome-keyring
    redshift
    wmctrl
    xdotool
    i3status-rust
    blueman
    networkmanagerapplet
  ];
  # Copy i3status-rust configuration
  home.file.".config/i3status-rust/config-default.toml".source = ./config-default.toml;

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod1";  # Use Alt key as modifier
      
      # Enable workspace back-and-forth functionality
      # This allows Alt+1 to switch back to previous workspace when pressed again
      workspaceAutoBackAndForth = true;

      # Window rules for workspace assignment and urgent hints
      window.commands = [
        # Force Firefox to always move to web workspace and focus it
        {
          command = "move to workspace \"1: web\", focus";
          criteria = { class = "^Firefox$"; };
        }
        # Disable urgent hints for startup applications
        {
          command = "urgent ignore";
          criteria = { class = "^Firefox$"; };
        }
        {
          command = "urgent ignore";
          criteria = { class = "^Code$"; title = "^VS Code Default$"; };
        }
        {
          command = "urgent ignore";
          criteria = { class = "^Code$"; title = "^VS Code Private$"; };
        }
        {
          command = "urgent ignore";
          criteria = { class = "^Logseq$"; };
        }
        {
          command = "urgent ignore";
          criteria = { class = "^Alacritty$"; };
        }
      ];

      # Assign applications to workspaces
      assigns = {
        "0: workspace" = [];
        "1: web" = [{ class = "^Firefox$"; }];
        "8: logseq" = [{ class = "^Logseq$"; }];
        "9: pw" = [{ class = "^KeePassXC$"; }];
      };

      # Autostart applications with delays to prevent race conditions
      startup = [
        { command = "/run/current-system/sw/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh"; notification = false; }
        # Set initial brightness and color temperature using redshift
        { command = "redshift -O 3500 -b 0.6"; notification = false; }
        # Start pwvucontrol for PipeWire volume control
        { command = "pwvucontrol"; notification = false; }
        # Start bluetooth applet
        { command = "sleep 1 && ${pkgs.blueman}/bin/blueman-applet"; notification = false; }
        # Start network manager applet
        { command = "sleep 1 && ${pkgs.networkmanagerapplet}/bin/nm-applet"; notification = false; }
        { command = "i3-msg 'workspace 3: term; exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux'"; notification = false; }
        { command = "sleep 2 && i3-msg 'workspace 8: logseq; exec ${pkgs.logseq}/bin/logseq'"; notification = false; }
        { command = "sleep 6 && i3-msg 'workspace 1: web; exec ${pkgs.firefox}/bin/firefox'"; notification = false; }
        { command = "sleep 8 && i3-msg 'workspace 2: code; exec ${pkgs.vscode}/bin/code; mark vscode_default'"; notification = false; }
        { command = "sleep 11 && i3-msg 'workspace 4: burp; exec ${pkgs.jdk}/bin/java -jar $(find /home/user/Downloads -name 'burpsuite_pro*.jar' -type f | sort -r | head -n1)'"; notification = false; }
        { command = "sleep 16 && i3-msg 'workspace 1: web'"; notification = false; }
        # Clear urgent flags after all apps have launched
        { command = "sleep 18 && clear-urgent"; notification = false; }
      ];

      # Basic keybindings
      keybindings = {
        # Terminal
        "Mod1+t" = "exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux";

        # Work directory
        "Mod1+h" = "exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux new-session '/home/user/git/github/monorepo/maxos/scripts/work-dir-tmux'";

        # Program launcher
        "Mod1+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";

        # Window management
        "Mod1+u" = "fullscreen toggle";
        "Mod1+f" = "fullscreen toggle";
        "Mod1+Shift+space" = "floating toggle";

        # Layout management
        "Mod1+e" = "layout toggle split";
        "Mod1+Shift+h" = "split h";
        "Mod1+v" = "split v";

        # Focus
        "Mod1+Left" = "focus left";
        "Mod1+Down" = "focus down";
        "Mod1+Up" = "focus up";
        "Mod1+Right" = "focus right";

        # Moving windows
        "Mod1+Shift+Left" = "move left";
        "Mod1+Shift+Down" = "move down";
        "Mod1+Shift+Up" = "move up";
        "Mod1+Shift+Right" = "move right";

        # Restart/reload i3
        "Mod1+Shift+c" = "kill";
        "Mod1+Shift+r" = "restart";

        # Screenshot binding
        "--release Print" = "exec /run/current-system/sw/bin/screenshot";

        # Media controls using pactl for PipeWire
        "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

        # Brightness controls using redshift-brightness script
        "XF86MonBrightnessUp" = "exec redshift-brightness up";
        "XF86MonBrightnessDown" = "exec redshift-brightness down";
        "F8" = "exec redshift-brightness up";
        "F7" = "exec redshift-brightness down";
        "Mod1+Shift+b" = "exec redshift -x";  # Reset redshift

        # Workspace switching
        "Mod1+0" = "workspace number 0: workspace";
        "Mod1+1" = "workspace number 1: web";
        "Mod1+2" = "workspace number 2: code";
        "Mod1+3" = "workspace number 3: term";
        "Mod1+4" = "workspace number 4: burp";
        "Mod1+5" = "workspace number 5: term";
        "Mod1+6" = "workspace number 6: term";
        "Mod1+7" = "workspace number 7: term";
        "Mod1+8" = "workspace number 8: logseq";
        "Mod1+9" = "workspace number 9: pw";

        # Move container to workspace
        "Mod1+Shift+0" = "move container to workspace 0: workspace";
        "Mod1+Shift+1" = "move container to workspace 1: web";
        "Mod1+Shift+2" = "move container to workspace 2: code";
        "Mod1+Shift+3" = "move container to workspace 3: term";
        "Mod1+Shift+4" = "move container to workspace 4: burp";
        "Mod1+Shift+5" = "move container to workspace 5: term";
        "Mod1+Shift+6" = "move container to workspace 6: term";
        "Mod1+Shift+7" = "move container to workspace 7: term";
        "Mod1+Shift+8" = "move container to workspace 8: logseq";
        "Mod1+Shift+9" = "move container to workspace 9: pw";

        # Screen locking
        "Mod1+x" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock -c 000000";

        # Open shell at tickets directory
        "Mod1+m" = "exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux new-session 'cd /home/user/mgp-monorepo/tickets && $SHELL'";

        # Quick launch frequently used applications
        "${config.xsession.windowManager.i3.config.modifier}+b" = "workspace 4: burp; exec ${pkgs.jdk}/bin/java -jar $(find /home/user/Downloads -name 'burpsuite_pro*.jar' -type f | sort -r | head -n1)";
        "${config.xsession.windowManager.i3.config.modifier}+n" = "exec ${pkgs.pcmanfm}/bin/pcmanfm";
        "${config.xsession.windowManager.i3.config.modifier}+l" = "exec ${pkgs.i3lock}/bin/i3lock -c 000000";
        "${config.xsession.windowManager.i3.config.modifier}+k" = "workspace 9: pw; exec ${pkgs.keepassxc}/bin/keepassxc";
        "${config.xsession.windowManager.i3.config.modifier}+Return" = "exec $HOME/.local/bin/rofi-launcher";
        "${config.xsession.windowManager.i3.config.modifier}+Shift+l" = "exec systemctl poweroff";
        "Mod1+c" = "exec ${pkgs.chromium}/bin/chromium";

        # Screenshot selection
        "--release Mod1+s" = "exec /run/current-system/sw/bin/screenshot --select";
        # For G16
        "--release Mod1+Shift+s" = "exec /run/current-system/sw/bin/screenshot";

        # Launch Firefox with burp profile
        "Mod1+Shift+Return" = "workspace 4: burp; exec ${pkgs.firefox}/bin/firefox -P burp";

        # Insert timestamp
        "Mod1+Shift+t" = "exec /run/current-system/sw/bin/insert-timestamp";
      };


      # Monitor assignments defined in host-specific config
      workspaceOutputAssign = [ ];
    };
  };
  
  assertions = [
    {
      assertion = dependenciesValid;
      message = "i3 window manager configuration has no hard dependencies";
    }
  ];
  };
}
