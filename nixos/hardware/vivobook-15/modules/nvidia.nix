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
in
{
  options.hardware.nvidia = {
    enable = mkEnableOption "Enable NVIDIA GPU";
  };
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {
      nvidia = {
        open = true;
        # package = config.boot.kernelPackages.nvidiaPackages.beta;
        modesetting.enable = true;
        powerManagement.enable = true;
        powerManagement.finegrained = true;

        prime = {
          offload.enable = true;
          amdgpuBusId = "PCI:4:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          vaapiVdpau
          nvidia-vaapi-driver
        ];
      };
    };

    environment = {
      sessionVariables = rec {
        GBM_BACKEND = "nvidia-drm"; #on my laptop, wayland crashed using this env
        LIBVA_DRIVER_NAME = "nvidia"; # hardware acceleration
        WLR_RENDERER = "vulkan";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        __GL_VRR_ALLOWED = "0";
        # WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line  
      };

      systemPackages = with pkgs; [
        nvidia-offload
        libva
        libva-utils
        glxinfo
      ];
    };
  };
}
