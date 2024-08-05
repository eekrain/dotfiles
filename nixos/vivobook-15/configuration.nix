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
    outputs.nixosModules.hardware
    outputs.nixosModules.desktop
    outputs.nixosModules.networking
    outputs.nixosModules.addons

    # Or modules from other flakes (such as nixos-hardware):
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-laptop-acpi_call
    inputs.chaotic.nixosModules.default
    # You can also split up your configuration and import pieces of it here:
    ../default-settings/default.nix
  ];

  # Enabling my custom nixos modules installed
  myModules = {
    hardware = {
      audio = true;
      bluetooth = true;
      gpu = lib.mkDefault "amd";
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
      clash = true;
      # redsocks = true;
    };
    desktop = {
      sddm.enable = true;
      sddm.defaultSession = "hyprland";
      hyprland = {
        enable = true;
        brightnessController = "light";
      };
      nautilus.enable = true;
    };
    addons = {
      nix-ld = true;
      devenv = true;
      enableAndroidAdb = false;
      enableDocker = false;
      enableVirtualbox = false;
    };
  };

  # TODO: Set your hostname
  networking.hostName = "eka-laptop";
  # TODO: Put your flake location dir here, for use with nh(nix helper tool)
  programs.nh.flake = lib.mkForce "/home/eekrain/dotfiles";

  # FIXME: Add the rest of your current configuration
  # use latest kernel
  # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  # chaotic.scx.enable = true;
  # chaotic.scx.scheduler = "scx_rusty";

  # IF for some reason your system can't boot up cause of bluetooth issue, add this line to add all linux firmware
  hardware.enableAllFirmware = true;
  # # use zramSwap
  # zramSwap.enable = true;
  # Spesific settings for ASUS Laptops
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
  services.supergfxd.enable = true;

  # Specialisation settings
  # Default boot loader configuration name using AMD GPU
  boot.loader.grub.configurationName = "AMD GPU";
  specialisation = {
    nvidia_gpu.configuration = {
      # Bootloader name for specialisation with NVIDIA GPU instead
      boot.loader.grub.configurationName = lib.mkForce "NVIDIA GPU";
      # Force change myModules.hardware.gpu to be "nvidia"
      myModules.hardware.gpu = lib.mkForce "amd+nvidia";
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
