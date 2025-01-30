{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      env = {
        TERM = "xterm-256color";
        SHELL = "${pkgs.zsh}/bin/zsh";
      };

      window = {
        padding = {
          x = 5;
          y = 5;
        };
        opacity = 0.95;
        decorations = "none";
        dynamic_title = true;
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        normal = {
          family = "MesloLGS Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "MesloLGS Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "MesloLGS Nerd Font Mono";
          style = "Italic";
        };
        size = 14.0;
        offset = {
          x = 0;
          y = 1;
        };
        glyph_offset = {
          x = 0;
          y = 0;
        };
      };

      # GitHub Dark Colorblind theme
      colors = {
        primary = {
          background = "#0d1117";
          foreground = "#b3b1ad";
        };
        normal = {
          black = "#484f58";
          red = "#ff7b72";
          green = "#3fb950";
          yellow = "#d29922";
          blue = "#58a6ff";
          magenta = "#bc8cff";
          cyan = "#39c5cf";
          white = "#b1bac4";
        };
        bright = {
          black = "#6e7681";
          red = "#ffa198";
          green = "#56d364";
          yellow = "#e3b341";
          blue = "#79c0ff";
          magenta = "#d2a8ff";
          cyan = "#56d4dd";
          white = "#f0f6fc";
        };
        indexed_colors = [
          { index = 16; color = "#d18616"; }
          { index = 17; color = "#ffa198"; }
        ];
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 750;
        blink_timeout = 5;
        unfocused_hollow = true;
        thickness = 0.15;
      };

      general = {
        live_config_reload = true;
      };

      keyboard.bindings = [
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "Insert"; mods = "Shift"; action = "PasteSelection"; }
        { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
        { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
        { key = "Plus"; mods = "Control"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
        { key = "F11"; action = "ToggleFullscreen"; }
      ];

      mouse = {
        hide_when_typing = false;
        bindings = [
          { mouse = "Middle"; action = "PasteSelection"; }
        ];
      };

      hints = {
        enabled = [
          {
            regex = "https?://[a-zA-Z0-9-._~:/?#@!$&'*+,;=%]+[^)]";
            binding = {
              key = "A";
              mods = "Alt";
            };
            command = "xdg-open";
          }
        ];
      };

      selection = {
        semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
        save_to_clipboard = true;
      };
    };
  };

  # Ensure required fonts are available
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Meslo" ]; })
  ];
}
