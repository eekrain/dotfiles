{ config, inputs, pkgs, lib, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    ./modules/myproxy.nix
    ./modules/amdgpu.nix
    ./modules/nvidia.nix
    ./bootloader.nix
    ./bluetooth.nix
    ./audio.nix
    ./networking.nix
    ./power-management.nix
  ];

  # Default Profile GPU
  boot.loader.grub.configurationName = "AMD Normal Network";
  hardware.amdgpu.enable = true;


  specialisation = {
    amd_proxied.configuration = {
      boot.loader.grub.configurationName = lib.mkForce "AMD + Proxy";

      services.myproxy.enable = lib.mkForce true;
      networking.firewall.enable = lib.mkForce true;
    };

    nvidia_proxied.configuration = {
      boot.loader.grub.configurationName = lib.mkForce "NVIDIA + Proxy";
      hardware.amdgpu.enable = lib.mkForce false;
      hardware.nvidia.enable = lib.mkForce true;

      services.myproxy.enable = lib.mkForce true;
      networking.firewall.enable = lib.mkForce true;
    };
  };

  # use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # IF for some reason your system can't boot up cause of bluetooth issue, add this line to add all linux firmware
  hardware.enableAllFirmware = true;
  # for android development
  programs.adb.enable = true;
}
