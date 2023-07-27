{ config, ... }:
{
  # Bootloader
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    grub = {
      configurationName = "Default";
      enable = true;
      version = 2;
      efiSupport = true;
      devices = [ "nodev" ];
      useOSProber = true;
    };
  };
}
