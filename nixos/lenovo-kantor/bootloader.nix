{ config, inputs, ... }:
{
  imports = [ inputs.grub2-themes.nixosModules.default ];

  # Bootloader
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    grub = {
      enable = true;
      efiSupport = true;
      devices = [ "nodev" ];
      useOSProber = true;
    };

    grub2-theme = {
      enable = true;
      theme = "tela";
      screen = "2k";
    };
  };
}
