{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.hardware;
in {
  config = mkIf (cfg.gpu == "amd+nvidia") {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
    hardware.amdgpu.initrd.enable = true;

    boot.blacklistedKernelModules = ["nouveau"];
    boot.kernelParams = ["nvidia-drm.fbdev=1"];
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

    # # If it's using nvidia, implement spesific sessionVariables
    # environment.sessionVariables = {
    #   GBM_BACKEND = "nvidia-drm"; #on my laptop, wayland crashed using this env
    #   LIBVA_DRIVER_NAME = "nvidia"; # hardware acceleration
    #   # WLR_RENDERER = "vulkan";
    #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    #   __GL_VRR_ALLOWED = "0";
    #   WLR_DRM_DEVICES = "/dev/dri/card0:/dev/dri/card1";
    #   WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line
    # };
  };
}
