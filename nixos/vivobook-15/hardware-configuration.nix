{ config, lib, pkgs, modulesPath, ... }:
{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "uas" "sd_mod" "usb_storage" "cryptd" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Encryption settings with luks
  boot.initrd.luks.devices.root = {
    device = "/dev/disk/by-partlabel/root";
    preLVM = true;
    allowDiscards = true;
  };

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
  # Use the swap partition here
  boot.resumeDevice = "/dev/disk/by-label/swap";

  # Mounting my windows partition
  boot.supportedFilesystems = [ "ntfs" ];
  fileSystems."/home/eekrain/MyWindows" = {
    device = "/dev/disk/by-uuid/7276265D762621F9";
    fsType = "ntfs-3g";
    # uid of the user, my eekrain user has uid of 1000
    options = [ "rw" "uid=1000" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
