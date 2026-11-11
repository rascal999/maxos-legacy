{ config, lib, pkgs, ... }:

let
  # Handy STT AppImage pinned from GitHub releases.
  # Run via the rig appimage-run wrapper so ALSA goes through PipeWire.
  handy-appimage = pkgs.runCommand "handy-0.9.8-appimage" { } ''
    mkdir -p $out/bin
    cp ${pkgs.fetchurl {
      url = "https://github.com/cjpais/Handy/releases/download/v0.9.8/Handy_0.9.8_amd64.AppImage";
      hash = "sha256-1oPclnYvmkeXUEWrSAOS0zpbSRlo+zNtysR+L2XnGE8=";
    }} $out/bin/handy
    chmod +x $out/bin/handy
  '';
in

{
  imports = [
    # Using layered home system like G16
    # ../../modules/home-profiles/development.nix  # Disabled - imports hybrid modules that conflict with layered structure
    # ../../modules/tools/logseq.nix               # Disabled - hybrid module conflicts with layered structure
    # ../../modules/tools/claude-code.nix          # Disabled - hybrid module conflicts with layered structure
  ];

  # Enable individual tools that need home-manager configuration
  # Note: Using layered system like G16
  maxos.tools = {
    # Terminal and shell
    zsh.enable = true;
    alacritty.enable = true;
    tmux.enable = true;
    
    # Window manager
    i3.enable = true;
    i3.autostartBurp = false;
    
    # Development tools
    direnv.enable = true;
    
    # Applications
    firefox.enable = true;
    logseq.enable = true;
    obsidian.enable = true;
    appflowy.enable = true;
    remmina.enable = true;

    # LM Studio — local LLM GUI
    lmstudio.enable = true;

    # OpenCode — dynamic agent & secret orchestration
    opencode.enable = true;

    # Zed editor
    zed-editor.enable = true;

    # Claude Code — agentic CLI coding tool
    claude-code.enable = true;

    # Happy Coder — mobile/web client for Claude Code
    happy-coder.enable = true;

  };

  # Home Manager needs a bit of information about you and the paths it should manage
  home = {
    username = "user";
    homeDirectory = lib.mkForce "/home/user";
    stateVersion = "25.11";  # Please read the comment below

    # The home.stateVersion option does not have a default and must be set
    # First time users of home-manager should read:
    # https://nix-community.github.io/home-manager/index.html#sec-install-standalone

    packages = with pkgs; [
      # Packages provided by layered system and tool bundles
      # Only unique packages not available through layered modules:
      aider-chat
      openai-whisper

      # Debugging / input tools
      xorg.xev

      # Fonts now managed centrally via maxos.fonts
    ];

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "alacritty";
    };

    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
    ];

    # File associations and scripts
    file = {
      ".screenlayout/dual-monitor.sh" = {
        executable = true;
        text = ''
          #!/bin/sh
          xrandr --output DP-4 --primary --mode 3440x1440 --rate 144 --pos 0x0
	  xrandr --output DP-2 --mode 2560x1440 --rate 120 --right-of DP-4
        '';
      };
      ".config/mimeapps.list".text = ''
        [Default Applications]
        text/html=firefox.desktop
        x-scheme-handler/http=firefox.desktop
        x-scheme-handler/https=firefox.desktop
        application/pdf=org.pwmt.zathura.desktop
      '';
      
      ".Xresources".text = ''
        Xft.dpi: 168
      '';

      # Make the Stacey Assistant script available and executable
      ".local/bin/start-stacey-assistant" = {
        source = ../../scripts/start-stacey-assistant.sh; # Path relative to this home.nix file
        executable = true;
      };
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Aidan Marlin";
    userEmail = "aidan@synlace.io";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
    };
  };

  # Additional program configurations
  programs = {

    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        ".." = "cd ..";
        "..." = "cd ../..";
        update = "sudo nixos-rebuild switch";
      };
    };

    fzf = {
      enable = true;
      enableBashIntegration = true;
    };
  };

  # Enable services
  services = {
    picom = {
      enable = true;
      vSync = false;
    };

    dunst = {
      enable = true;
      settings = {
        global = {
          font = "JetBrainsMono Nerd Font 10";
          frame_width = 2;
          frame_color = "#4c566a";
        };
      };
    };

    easyeffects = {
      enable = true;
      preset = "default";
    };
  };

  # Systemd user service for Stacey Assistant
  systemd.user.services.stacey-assistant = {
    Unit = {
      Description = "Stacey Assistant Service";
      # Start after the graphical session is ready, adjust if network is needed earlier
      After = [ "graphical-session.target" ];
    };
    Service = {
      # Execute the script using bash from Nix packages
      ExecStart = "${pkgs.bash}/bin/bash ${config.home.homeDirectory}/.local/bin/start-stacey-assistant";
      Restart = "on-failure"; # Restart the service if it fails
      RestartSec = "10s";      # Wait 10 seconds before restarting
    };
    Install = {
      WantedBy = [ "graphical-session.target" ]; # Ensure it's started with the user session
    };
  };

  # Systemd user service for Handy (AppImage, pinned release)
  systemd.user.services.handy = {
    Unit = {
      Description = "Handy Speech-to-Text Assistant (AppImage)";
      After = [ "graphical-session.target" "direct-ptt.service" ];
      # Wants instead of Requires: a direct-ptt restart must not stop Handy
      Wants = [ "direct-ptt.service" ];
    };
    Service = {
      # /run/current-system/sw/bin/appimage-run is the rig ALSA/PipeWire-aware wrapper
      ExecStart = "/run/current-system/sw/bin/appimage-run ${handy-appimage}/bin/handy";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Relay adb (5555) to WireGuard hosts: socat listens on the rig WireGuard
  # address (bootstrap-2: 10.66.0.3) and forwards to the USB-attached phone
  # through the adb server's forward. Requires the phone in tcpip mode once:
  # adb tcpip 5555
  systemd.user.services.adb-relay = {
    Unit = {
      Description = "adb 5555 relay to WireGuard hosts (socat -> adb forward)";
      After = [ "graphical-session.target" ];
    };
    Service = {
      # -d selects the USB phone even while network adb devices are connected
      ExecStartPre = "${pkgs.android-tools}/bin/adb start-server && ${pkgs.android-tools}/bin/adb -d forward tcp:5555 tcp:5555";
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:5555,fork,reuseaddr,bind=10.66.0.3 TCP:127.0.0.1:5555";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Keep the adb forward alive: a USB/transport bounce clears forwards while
  # the socat listener keeps running (adb would show "offline"). --no-rebind
  # only creates the forward when it is missing, so live sessions are safe.
  systemd.user.services.adb-forward-keepalive = {
    Unit = {
      Description = "Re-assert adb forward for the 5555 relay";
    };
    Service = {
      Type = "oneshot";
      # -d selects the USB phone; --no-rebind keeps existing forwards untouched
      ExecStart = "${pkgs.bash}/bin/sh -c '${pkgs.android-tools}/bin/adb start-server; ${pkgs.android-tools}/bin/adb -d forward --no-rebind tcp:5555 tcp:5555 || true'";
    };
  };

  systemd.user.timers.adb-forward-keepalive = {
    Unit = {
      Description = "Re-assert adb forward every 30s";
    };
    Timer = {
      OnBootSec = "15s";
      OnUnitActiveSec = "30s";
      AccuracySec = "5s";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # User service for Push-to-Talk
  # Note: Ensure the user 'user' is part of the 'input' group at the system level
  # (e.g., in users.nix: users.users.user.extraGroups = [ "input" ];)
  # for /dev/input/event* access needed by the python-ptt.py script.

  # i3 configuration for rig
  xsession.windowManager.i3.config = {
    # Monitor setup in startup
    startup = [
      { command = "$HOME/.screenlayout/dual-monitor.sh"; notification = false; }
      { command = "i3-msg 'debuglog on; shmlog on; shmlog size 26214400'"; notification = false; }
      # Delay unmuting and setting default source by 5 seconds to ensure PipeWire is fully initialized first on login
      { command = "sh -c 'sleep 5 && ${pkgs.pulseaudio}/bin/pactl set-default-source alsa_input.usb-Jieli_Technology_USB_Composite_Device_433130393139312E-00.pro-input-0 && ${pkgs.pulseaudio}/bin/pactl set-source-mute alsa_input.usb-Jieli_Technology_USB_Composite_Device_433130393139312E-00.pro-input-0 0'"; notification = false; }
    ];

    # Workspace monitor assignments
    workspaceOutputAssign = [
      # Right monitor - General workspace
      { workspace = "0: workspace"; output = "DP-2"; }
      # Right monitor - Code
      { workspace = "2: code"; output = "DP-2"; }
      # All other workspaces on ultrawide
      { workspace = "1: web"; output = "DP-4"; }
      { workspace = "3: pcode"; output = "DP-4"; }
      { workspace = "4: term"; output = "DP-4"; }
      { workspace = "5: burp"; output = "DP-4"; }
      { workspace = "6: goose"; output = "DP-4"; }
      { workspace = "8: logseq"; output = "DP-4"; }
      { workspace = "9: pw"; output = "DP-4"; }
    ];
  };
}
