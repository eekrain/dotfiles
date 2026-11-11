# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
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
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.asus-battery

    # You can also split up your configuration and import pieces of it here:
    ../eekrain.nix
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
      unbound = true;
      cloudflare-warp = true;
      clash = false;
      # redsocks = true;
    };
    desktop = {
      sddm.enable = true;
      greetd.enable = false;
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
      android = true;
      docker = true;
      virtualbox = false;
      waydroid = true;
      streaming = true;
      httpd.enable = true;
      gaming = true;
    };
  };

  # TODO: Set your hostname
  networking.hostName = "eka-laptop";
  # TODO: Put your flake location dir here, for use with nh(nix helper tool)
  programs.nh.flake = lib.mkForce "/home/eekrain/dotfiles";

  # FIXME: Add the rest of your current configuration
  # boot.kernelPackages = pkgs.linuxPackages;

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts;
  # snd_hda_intel position_fix=2: with position_fix=auto (default), the HDA
  # controller's DMA position reads glitch every few seconds on this Cezanne
  # + ALC294 laptop -> periodic audio underruns ("crackle"), which in
  # Chromium/Firefox freezes the media clock (audio-driven) and stalls/pauses
  # video playback on fully-buffered streams. Forcing DMA position-buffer
  # reads (2) fixes both. Found 2026-11-11; if a future kernel update
  # changes behavior, also try position_fix=4 (direct LPIB reads).
  boot.extraModprobeConfig = ''
    options snd_hda_intel position_fix=2
  '';
  services.scx-loader = {
    enable = true;
    config = {
      default_sched = "scx_bpfland";
      scheds.scx_bpfland.auto_mode = [
        "-m"
        "performance"
        "-w"
      ];
    };
  };

  # DNS tools for testing
  environment.systemPackages = with pkgs; [ dnsutils ];

  # IF for some reason your system can't boot up cause of bluetooth issue, add this line to add all linux firmware
  hardware.enableAllFirmware = true;
  # # use zramSwap
  zramSwap.enable = true;
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
  system.stateVersion = "25.11";
}
