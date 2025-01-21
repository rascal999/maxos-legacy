{ config, lib, pkgs, ... }:

{
  programs.home-manager.enable = true;
  
  home.packages = with pkgs; [
    i3status
    i3lock
    dmenu
    gnome-keyring
    redshift
  ];

  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod1";  # Use Alt key as modifier

      # Assign applications to workspaces
      assigns = {
        "1: web" = [{ class = "^Firefox$"; }];
        "2: code" = [{ class = "^Code$"; }];
        "8: logseq" = [{ class = "^Logseq$"; }];
      };

      # Autostart applications with delays to prevent race conditions
      startup = [
        { command = "/run/current-system/sw/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh"; notification = false; }
        # Set initial brightness and color temperature using redshift
        { command = "redshift -O 3500 -b 0.6"; notification = false; }
        { command = "sleep 1 && i3-msg 'workspace 1: web; exec ${pkgs.firefox}/bin/firefox'"; notification = false; }
        { command = "sleep 2 && i3-msg 'workspace 2: code; exec ${pkgs.vscode}/bin/code'"; notification = false; }
        { command = "sleep 1 && i3-msg 'workspace 3: term; exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux'"; notification = false; }
        { command = "sleep 3 && i3-msg 'workspace 8: logseq; exec ${pkgs.logseq}/bin/logseq'"; notification = false; }
      ];

      # Basic keybindings
      keybindings = {
        # Terminal
        "Mod1+t" = "exec ${pkgs.alacritty}/bin/alacritty -e ${pkgs.tmux}/bin/tmux";
        
        # Program launcher
        "Mod1+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";
        
        # Window management
        "Mod1+u" = "fullscreen toggle";
        "Mod1+f" = "fullscreen toggle";
        "Mod1+Shift+space" = "floating toggle";
        
        # Layout management
        "Mod1+s" = "layout stacking";
        "Mod1+w" = "layout tabbed";
        "Mod1+e" = "layout toggle split";
        "Mod1+h" = "split h";
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

        # Screenshot bindings
        "Print" = "exec ${pkgs.flameshot}/bin/flameshot gui";
        "Shift+Print" = "exec ${pkgs.flameshot}/bin/flameshot full";

        # Media controls using pactl for PipeWire
        "XF86AudioRaiseVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec --no-startup-id ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
        
        # Brightness controls using brightness script with redshift
        "XF86MonBrightnessUp" = "exec ${config.home.homeDirectory}/maxos/modules/desktop/brightness.sh up";
        "XF86MonBrightnessDown" = "exec ${config.home.homeDirectory}/maxos/modules/desktop/brightness.sh down";
        "F8" = "exec ${config.home.homeDirectory}/maxos/modules/desktop/brightness.sh up";
        "F7" = "exec ${config.home.homeDirectory}/maxos/modules/desktop/brightness.sh down";
        "Mod1+Shift+b" = "exec ${config.home.homeDirectory}/maxos/modules/desktop/brightness.sh reset";
        
        # Workspace switching
        "Mod1+1" = "workspace number 1: web";
        "Mod1+2" = "workspace number 2: code";
        "Mod1+3" = "workspace number 3: term";
        "Mod1+4" = "workspace number 4: burp";
        "Mod1+5" = "workspace number 5: term";
        "Mod1+8" = "workspace number 8: logseq";
        
        # Move container to workspace
        "Mod1+Shift+1" = "move container to workspace 1: web";
        "Mod1+Shift+2" = "move container to workspace 2: code";
        "Mod1+Shift+3" = "move container to workspace 3: term";
        "Mod1+Shift+4" = "move container to workspace 4: burp";
        "Mod1+Shift+5" = "move container to workspace 5: term";
        "Mod1+Shift+8" = "move container to workspace 8: logseq";

        # Screen locking
        "Mod1+x" = "exec --no-startup-id ${pkgs.i3lock}/bin/i3lock -c 000000";

        # Quick launch frequently used applications
        "${config.xsession.windowManager.i3.config.modifier}+b" = "exec ${pkgs.firefox}/bin/firefox";
        "${config.xsession.windowManager.i3.config.modifier}+n" = "exec ${pkgs.pcmanfm}/bin/pcmanfm";
        "${config.xsession.windowManager.i3.config.modifier}+l" = "exec ${pkgs.i3lock}/bin/i3lock -c 000000";
        "${config.xsession.windowManager.i3.config.modifier}+Return" = "exec $HOME/.local/bin/rofi-launcher";
        "${config.xsession.windowManager.i3.config.modifier}+Shift+l" = "exec systemctl poweroff";
      };

      # Workspace configuration
      workspaceOutputAssign = [
        { workspace = "1: web"; output = "primary"; }
        { workspace = "2: code"; output = "primary"; }
        { workspace = "3: term"; output = "primary"; }
        { workspace = "4: burp"; output = "primary"; }
        { workspace = "5: term"; output = "primary"; }
        { workspace = "8: logseq"; output = "primary"; }
      ];

      # Basic appearance settings
      bars = [{
        position = "bottom";
        statusCommand = "${pkgs.i3status}/bin/i3status";
        colors = {
          background = "#2e3440";
          statusline = "#eceff4";
          separator = "#4c566a";
        };
      }];

      # Window appearance
      gaps = {
        inner = 0;
        outer = 0;
        smartGaps = true;
      };

      # Window decorations
      window = {
        border = 0;
        titlebar = false;
        commands = [
          { command = "border pixel 0"; criteria = { class = "^.*"; }; }
        ];
      };
    };
  };
}
