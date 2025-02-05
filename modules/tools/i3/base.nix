{ config, lib, pkgs, ... }:

{
  imports = [
    ./status.nix
    ./appearance.nix
  ];

  programs.home-manager.enable = true;

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
  ];

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod1";  # Use Alt key as modifier

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
          criteria = { class = "^Code$"; };
        }
        {
          command = "urgent ignore";
          criteria = { class = "^Slack$"; };
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
        "0: slack" = [{ class = "^Slack$"; }];
        "1: web" = [{ class = "^Firefox$"; }];
        "2: code" = [{ class = "^Code$"; }];
        "8: logseq" = [{ class = "^Logseq$"; }];
        "9: pw" = [{ class = "^KeePassXC$"; }];
      };

      # Autostart applications with delays to prevent race conditions
      startup = [
        { command = "/run/current-system/sw/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh"; notification = false; }
        # Set initial brightness and color temperature using redshift
        { command = "redshift -O 3500 -b 0.6"; notification = false; }
        # Start pasystray for volume control
        { command = "sleep 2 && pasystray"; notification = false; }
        # Launch Firefox first and ensure it's on workspace 1
        { command = "i3-msg 'workspace 1: web; exec ${pkgs.firefox}/bin/firefox'"; notification = false; }
        { command = "sleep 2 && i3-msg 'workspace 1: web'"; notification = false; }
        # Launch other applications after Firefox is settled
        { command = "sleep 3 && i3-msg 'workspace 0: slack; exec ${pkgs.slack}/bin/slack'"; notification = false; }
        { command = "sleep 4 && i3-msg 'workspace 8: logseq; exec ${pkgs.logseq}/bin/logseq'"; notification = false; }
        { command = "sleep 5 && i3-msg 'workspace 2: code; exec ${pkgs.vscode}/bin/code'"; notification = false; }
        { command = "sleep 6 && i3-msg 'workspace 3: goose; exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux new-session \"/home/user/git/github/monorepo/tools/goose/docker/run-goose.sh session\"'"; notification = false; }
        { command = "sleep 7 && i3-msg 'workspace 4: term; exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux'"; notification = false; }
        { command = "sleep 8 && i3-msg 'workspace 1: web'"; notification = false; }
        # Clear urgent flags after all apps have launched
        { command = "sleep 12 && clear-urgent"; notification = false; }
      ];

      # Basic keybindings
      keybindings = {
        # Terminal
        "Mod1+t" = "exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux";

        # Work directory
        "Mod1+h" = "exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux new-session ${../../../scripts/work-dir-tmux}";
        "Mod1+w" = "exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux new-session 'cd /home/user/monorepo/tools/goose/workspace && eza --long --all --header --icons --git && $SHELL'";

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
        "Mod1+0" = "workspace number 0: slack";
        "Mod1+1" = "workspace number 1: web";
        "Mod1+2" = "workspace number 2: code";
        "Mod1+3" = "workspace number 3: goose";
        "Mod1+4" = "workspace number 4: term";
        "Mod1+5" = "workspace number 5: burp";
        "Mod1+8" = "workspace number 8: logseq";
        "Mod1+9" = "workspace number 9: pw";

        # Move container to workspace
        "Mod1+Shift+0" = "move container to workspace 0: slack";
        "Mod1+Shift+1" = "move container to workspace 1: web";
        "Mod1+Shift+2" = "move container to workspace 2: code";
        "Mod1+Shift+3" = "move container to workspace 3: goose";
        "Mod1+Shift+4" = "move container to workspace 4: term";
        "Mod1+Shift+5" = "move container to workspace 5: burp";
        "Mod1+Shift+8" = "move container to workspace 8: logseq";
        "Mod1+Shift+9" = "move container to workspace 9: pw";

        # Screen locking
        "Mod1+x" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock -c 000000";

        # Quick launch frequently used applications
        "${config.xsession.windowManager.i3.config.modifier}+b" = "workspace 5: burp; exec ${pkgs.jdk}/bin/java -jar $(find /home/user/Downloads -name 'burpsuite_pro*.jar' -type f | sort -r | head -n1)";
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

        # Insert timestamp
        "Mod1+Shift+t" = "exec /run/current-system/sw/bin/insert-timestamp";
      };


      # Monitor assignments defined in host-specific config
      workspaceOutputAssign = [ ];
    };
  };
}
