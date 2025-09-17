{ config, pkgs, lib, ... }:

{
  # User configuration for minimal rig testing
  users.users.user = {
    isNormalUser = true;
    description = "Test User";
    extraGroups = [ 
      "wheel"          # sudo access
      "networkmanager" # network management
      "audio"          # audio access
      "video"          # video access
    ];
    
    # Use simple password for testing: "test123"
    hashedPassword = "$6$rounds=4096$salt$IxDD3jeSOb5eB1CX.VxBGuJd5u.kVp1336chMQ0Bpx8qooXAT.At25XMxn0hJR6w8wFaQKGPv2zqRUVRAA.";
    
    # Enable SSH key authentication
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here for remote access
    ];
  };

  # Enable sudo without password for testing
  security.sudo.wheelNeedsPassword = false;
  
  # Basic user environment
  environment.systemPackages = with pkgs; [
    vim
    htop
    tree
  ];
}