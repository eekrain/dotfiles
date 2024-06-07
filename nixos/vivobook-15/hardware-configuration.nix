{ config, lib, pkgs, modulesPath, ... }:
{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "uas" "sd_mod" "usb_storage" "cryptd" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/root";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
    };

  fileSystems."/nix" =
    {
      device = "/dev/disk/by-label/nix-store";
      fsType = "ext4";
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-label/home";
      fsType = "ext4";
    };

  swapDevices =
    [{ device = "/dev/disk/by-label/swap"; }];

  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-partlabel/root";
    preLVM = true;
    allowDiscards = true;
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
