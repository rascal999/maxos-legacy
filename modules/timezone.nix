{ config, lib, pkgs, ... }:

{
  # Set time zone to Europe/London (includes BST during summer)
  time.timeZone = "Europe/London";
  
  # Enable automatic time synchronization
  services.timesyncd.enable = true;
}