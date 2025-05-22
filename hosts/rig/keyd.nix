{ config, pkgs, ... }:

{
  services.keyd = {
    enable = true;
    keyboards = {
      # This is a placeholder. We'll need to configure your actual keyboard(s).
      # For example, if your keyd configuration file is at /etc/keyd/default.conf
      # and refers to a keyboard named "internal-keyboard", you might have:
      # "internal-keyboard" = {
      #   ids = [ "*" ]; # Or specific vendor/product IDs like "1234:5678"
      #   settings = {
      #     main = pkgs.writeText "keyd-internal-keyboard-conf" ''
      #       # Your keyd configuration content for this keyboard goes here
      #       # For example:
      #       [ids]
      #       *
      #
      #       [main]
      #       capslock = overload(control, esc)
      #     '';
      #   };
      # };
    };
  };
}