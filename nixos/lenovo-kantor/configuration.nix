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
    ./bootloader.nix

    # If you want to use modules your own flake exports (from modules/nixos):
    outputs.nixosModules.default-settings
    outputs.nixosModules.hardware
    outputs.nixosModules.desktop
    outputs.nixosModules.networking
    outputs.nixosModules.addons

    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    # You can also split up your configuration and import pieces of it here:
    ../eekrain.nix
  ];

  # Enabling my custom nixos modules installed
  myModules = {
    hardware = {
      audio = true;
      bluetooth = true;
      powerManagement = true;
      suspendThenHybernate = {
        enable = true;
        hibernateAfterSuspendSeconds = 1800;
      };
    };
    networking = {
      enable = true;
      cloudflared = true;
      cloudflare-warp = true;
      # clash = false;
      # redsocks = true;
    };
    desktop = {
      greetd.enable = true;
      hyprland = {
        enable = true;
        brightnessController = "brightnessctl";
      };
      nautilus.enable = true;
    };
    addons = {
      nix-ld = true;
      devenv = true;
      flatpak = false;
      androidAdb = false;
      docker = true;
      virtualbox = false;
      waydroid = false;
    };
  };

  # TODO: Set your hostname
  networking.hostName = "lenovo-kantor";
  # TODO: Put your flake location dir here, for use with nh(nix helper tool)
  programs.nh.flake = lib.mkForce "/home/eekrain/dotfiles";

  # FIXME: Add the rest of your current configuration
  # use latest kernel
  # boot.kernelPackages = pkgs.linuxPackages_cachyos;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # chaotic.scx.enable = true;
  # chaotic.scx.scheduler = "scx_rusty";

  # IF for some reason your system can't boot up cause of bluetooth issue, add this line to add all linux firmware
  hardware.enableAllFirmware = true;
  # # use zramSwap
  zramSwap.enable = true;
  zramSwap.memoryPercent = 75;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
