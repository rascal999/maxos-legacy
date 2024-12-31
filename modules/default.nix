# Custom NixOS modules
{
  imports = [
    # User configuration module
    ./user-config    # Directory containing split user configuration modules
  ];
}
