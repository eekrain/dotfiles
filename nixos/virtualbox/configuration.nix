# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.hardware
    outputs.nixosModules.desktop
    outputs.nixosModules.networking
    outputs.nixosModules.addons

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd

    # You can also split up your configuration and import pieces of it here:
    ../default-settings/default.nix
  ];

  # Enabling my custom nixos modules installed
  myModules = {
    hardware = {
      audio = false;
      bluetooth = false;
      gpu = null;
      suspendThenHybernate = {
        enable = false;
        # hibernateAfterSuspendSeconds = 30;
      };
    };
    networking = {
      enable = true;
      proxyWith = null;
      # proxyWith = "redsocks";
    };
    desktop = {
      sddm.enable = true;
      hyprland.enable = true;
      nautilus.enable = true;
    };
    addons = {
      enableAndroidAdb = false;
      enableDocker = false;
      enableVirtualbox = false;
    };
  };

  # Put your flake location dir here, for use with nh(nix helper tool)
  programs.nh.flake = lib.mkForce "/home/eekrain/dotfiles";

  # TODO: Set your hostname
  networking.hostName = "virtualbox";

  # FIXME: Add the rest of your current configuration
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
