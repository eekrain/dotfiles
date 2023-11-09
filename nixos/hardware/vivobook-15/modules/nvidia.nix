{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.hardware.nvidia;

  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';

  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.beta;
in
{
  options.hardware.nvidia = {
    enable = mkEnableOption "Enable NVIDIA GPU";
  };
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ]; # Wayland

    hardware = {
      nvidia = {
        package = nvidiaPackage;

        # Open drivers (NVreg_OpenRmEnableUnsupportedGpus=1)
        open = false;
        nvidiaSettings = true;

        # nvidia-drm.modeset=1
        modesetting.enable = true;

        # NVreg_PreserveVideoMemoryAllocations=1
        powerManagement.enable = true;
        # powerManagement.finegrained = true;

        prime = {
          offload.enable = true;
          amdgpuBusId = "PCI:4:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };

      opengl = {
        enable = true;
        driSupport = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          libvdpau-va-gl
          nvidia-vaapi-driver
        ];
      };
    };

    environment = {
      systemPackages = with pkgs; [
        nvidia-offload
        glxinfo

        egl-wayland
        glfw-wayland
        mesa-demos
        libva
        libva-utils
      ];
    };
  };
}
