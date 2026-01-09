{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.maxos.tools.pandoc;
in {
  options.maxos.tools.pandoc = {
    enable = mkEnableOption "Pandoc universal document converter";
    
    includeExtensions = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to include additional format support (LaTeX, fonts, etc.)";
    };
  };

  config = mkIf cfg.enable {
    # Install Pandoc package
    environment.systemPackages = with pkgs; [
      # Core Pandoc package
      pandoc
      
      # Additional tools for extended format support
    ] ++ optionals cfg.includeExtensions [
      # LaTeX support for PDF generation with XeLaTeX
      texlive.combined.scheme-full  # Full LaTeX distribution for maximum compatibility
      
      # Font packages for XeLaTeX/LuaLaTeX
      # Common fonts that templates might use
      liberation_ttf          # Liberation fonts (Arial, Times New Roman alternatives)
      dejavu_fonts           # DejaVu fonts
      freefont_ttf           # GNU FreeFont
      noto-fonts             # Google Noto fonts
      noto-fonts-cjk-sans    # CJK (Chinese, Japanese, Korean) support
      noto-fonts-color-emoji # Emoji support
      font-awesome           # Icon fonts
      
      # Professional fonts
      source-sans-pro        # Adobe Source Sans Pro
      source-serif-pro       # Adobe Source Serif Pro
      source-code-pro        # Adobe Source Code Pro (monospace)
    ];
    
    # Enable fontconfig for proper font discovery
    fonts.packages = mkIf cfg.includeExtensions (with pkgs; [
      liberation_ttf
      dejavu_fonts
      freefont_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
      source-sans-pro
      source-serif-pro
      source-code-pro
    ]);
  };
}