{ config, inputs, pkgs, ... }:
{
  imports = [
    ./bluetooth
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-laptop-ssd
  ];

  # use latest kernel
  boot.kernelPackages = pkgs.unstable.linuxPackages_latest;

  # IF for some reason your system can't boot up cause of bluetooth issue, add this line to add all linux firmware
  hardware.enableAllFirmware = true;
}
