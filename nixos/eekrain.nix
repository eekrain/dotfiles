{
  lib,
  config,
  pkgs,
  ...
}: {
  # Add home manager settings to rebuild together with nixos-rebuild
  home-manager.users.eekrain = import ../home-manager/eekrain.nix;

  # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # FIXME: Replace with your username
    eekrain = {
      isNormalUser = true;
      description = "Ardian Eka Candra";
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      initialPassword = "eka";
      # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = ["wheel" "redsocks" "audio" "adbusers" "libvirtd" "networkmanager" "video" "docker" "warp"];
      # Setting zsh as default shell
      shell = pkgs.zsh;
    };
  };
}
