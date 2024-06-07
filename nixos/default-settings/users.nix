{ inputs, outputs, lib, config, pkgs, ... }: {

  imports = [
    # Adding home manager modules
    # To rebuild home manager settings together with nixos-rebuild
    inputs.home-manager.nixosModules.home-manager
  ];

  # Add home manager settings to rebuild together with nixos-rebuild 
  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      # Import your home-manager configuration
      eekrain = import ../../home-manager/eekrain.nix;
    };
  };

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # FIXME: Replace with your username
    eekrain = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "eka";
      isNormalUser = true;
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [ "wheel" "redsocks" "audio" "vboxsf" "adbusers" "libvirtd" "networkmanager" "video" "docker" ];
    };
  };
}
