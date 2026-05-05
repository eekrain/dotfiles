{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.myModules.hardware;
in
{
  config = mkIf (cfg.gpu == "amd+nvidia") {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    hardware.amdgpu.initrd.enable = true;

    boot.initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];

    boot.blacklistedKernelModules = [ "nouveau" ];
    boot.kernelParams = [ "nvidia-drm.fbdev=1" ];
    hardware.nvidia = {
      # Using beta driver
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      # Open drivers (NVreg_OpenRmEnableUnsupportedGpus=1)
      open = mkForce false;
      # Install nvidia settings app
      nvidiaSettings = true;
      # nvidia-drm.modeset=1
      modesetting.enable = true;
      # Power management setting, vivobook pro 15 is using nvidia rtx 3050
      # My device dont have problem setting powermanagement to true
      # if ur device isnt running well, set powerManagement value below to be false
      powerManagement.enable = true;
      powerManagement.finegrained = true;

      # Nvidia PRIME settings
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        amdgpuBusId = "PCI:4:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    # 1. This is the big one that usually satisfies the check
    services.xserver.videoDrivers = [ "nvidia" ];

    # 2. You already have this, but keep it
    hardware.nvidia-container-toolkit.enable = true;

    # 3. This is the "emergency bypass" that overrides the error you're seeing
    hardware.nvidia-container-toolkit.suppressNvidiaDriverAssertion = true;

    environment.sessionVariables = {
      AQ_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
    };
  };
}
