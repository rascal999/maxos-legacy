# Auto-shutdown module for MaxOS following layered architecture guidelines
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.services.auto-shutdown;
  
  dependenciesValid = 
    config.maxos.user.enable or true;

in {
  options.maxos.services.auto-shutdown = {
    enable = mkEnableOption "Automatic computer shutdown with warning notifications";
    
    time = mkOption {
      type = types.str;
      default = "22:45";
      description = "Time to shut down the computer (24-hour HH:MM format)";
    };
  };

  config = mkIf (cfg.enable && dependenciesValid) {
    systemd.services.auto-shutdown = {
      description = "Check and warn before automatic system shutdown";
      path = [ pkgs.util-linux pkgs.libnotify pkgs.procps ];
      
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = pkgs.writeShellScript "auto-shutdown" ''
          set -euo pipefail
          
          SHUTDOWN_TIME="${cfg.time}"
          
          # Parse hours and minutes
          TARGET_HOUR=''${SHUTDOWN_TIME%%:*}
          TARGET_MIN=''${SHUTDOWN_TIME##*:}
          
          CURRENT_HOUR=$(date +%H)
          CURRENT_MIN=$(date +%M)
          
          # Convert to total minutes from midnight, using 10# to force base-10 parsing
          TARGET_TOTAL_MINS=$(( 10#$TARGET_HOUR * 60 + 10#$TARGET_MIN ))
          CURRENT_TOTAL_MINS=$(( 10#$CURRENT_HOUR * 60 + 10#$CURRENT_MIN ))
          
          DIFF_MINUTES=$(( TARGET_TOTAL_MINS - CURRENT_TOTAL_MINS ))
          
          MSG=""
          case "$DIFF_MINUTES" in
            30) MSG="This computer is scheduled to shut down in 30 minutes (at ${cfg.time})." ;;
            10) MSG="This computer is scheduled to shut down in 10 minutes (at ${cfg.time})." ;;
            5)  MSG="This computer is scheduled to shut down in 5 minutes (at ${cfg.time})." ;;
            3)  MSG="This computer is scheduled to shut down in 3 minutes (at ${cfg.time})." ;;
            2)  MSG="This computer is scheduled to shut down in 2 minutes (at ${cfg.time})." ;;
            0)
              echo "Shutting down the computer now..." | wall || true
              shutdown -h now
              exit 0
              ;;
          esac
          
          if [ -n "$MSG" ]; then
            echo "WARNING: $MSG" | wall || true
            
            # Send graphical notification if 'user' is logged in
            if id -u user >/dev/null 2>&1; then
              # Attempt to notify the user on display :0
              # Using runuser to execute notify-send as the desktop user with proper DBUS session variables
              runuser -u user -- env DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send \
                -u critical \
                -i dialog-warning \
                "System Shutdown Warning" \
                "$MSG" || true
            fi
          fi
        '';
      };
    };

    systemd.timers.auto-shutdown = {
      description = "Trigger automatic shutdown checker every minute";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/1"; # Run every minute
        Unit = "auto-shutdown.service";
      };
    };

    assertions = [
      {
        assertion = dependenciesValid;
        message = "auto-shutdown requires the user module to be enabled";
      }
    ];
  };
}
