{ config, pkgs, lib, ... }:

{
  options.modules.tools.remmina = {
    enable = lib.mkEnableOption "Remmina remote desktop client";
    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to start Remmina automatically on boot";
    };
  };

  config = lib.mkIf config.modules.tools.remmina.enable {
    # Add Remmina and related packages to system packages
    environment.systemPackages = with pkgs; [
      remmina
      # Optional dependencies for various protocols
      freerdp    # For RDP support
      libvncserver  # For VNC support
      spice-gtk  # For SPICE support
    ];

    # Create a systemd user service for Remmina
    systemd.user.services.remmina = lib.mkIf config.modules.tools.remmina.autostart {
      description = "Remmina Remote Desktop Client";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.remmina}/bin/remmina -i";  # -i flag starts minimized to tray
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # Ensure Remmina's configuration directory exists
    home-manager.users.user = { pkgs, ... }: {
      home.file.".config/remmina/remmina.pref".text = ''
        [remmina_pref]
        auto_scroll=true
        hide_toolbar=false
        hide_statusbar=false
        small_toolbutton=false
        view_file_mode=0
        resolutions=640x480,800x600,1024x768,1152x864,1280x960,1400x1050
        main_width=600
        main_height=400
        main_maximize=false
        main_sort_column_id=1
        main_sort_order=0
        expanded_group=
        toolbar_pin_down=false
        sshtunnel_port=4732
        applet_new_ontop=false
        applet_hide_count=false
        applet_enable_avahi=false
        disable_tray_icon=false
        dark_tray_icon=false
        recent_maximum=10
        default_mode=0
        tab_mode=0
        fullscreen_toolbar_visibility=0
        auto_scroll_step=10
        hostkey=65508
        shortcutkey_fullscreen=102
        shortcutkey_autofit=49
        shortcutkey_nexttab=65363
        shortcutkey_prevtab=65361
        shortcutkey_scale=115
        shortcutkey_grab=103
        shortcutkey_viewonly=109
        shortcutkey_screenshot=65481
        shortcutkey_minimize=65478
        shortcutkey_disconnect=65473
        shortcutkey_toolbar=116
        scale_quality=0
        ssh_loglevel=1
        ssh_parseconfig=true
        hide_local_cursor=0
        screenshot_path=
        deny_screenshot_clipboard=false
        save_view_mode=true
        use_primary_password=false
        unlock_timeout=0
        unlock_password=
        trust_all=false
        floating_toolbar_placement=0
        toolbar_placement=3
        prevent_snap_welcome_message=false
        last_success_welcome_message=0
        autostart=true
        always_show_tab=true
        hide_connection_toolbar=false
        hide_searchbar=false
        default_action=0
        scale_mode=0
        grab_color=rgb(0,0,0)
        grab_color_switch=false
        confirm_close=true
        use_client_side_decoration=true
        minimize_to_tray=true
        start_in_tray=true
      '';
    };
  };
}