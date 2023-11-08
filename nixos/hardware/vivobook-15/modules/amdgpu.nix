{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.hardware.amdgpu;
in
{
  options.hardware.amdgpu = {
    enable = mkEnableOption "Enable AMD GPU";
  };

  config = mkIf cfg.enable {
    services.xserver.videoDrivers = [ "modesetting" ];

    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };

    boot.initrd.kernelModules = [ "amdgpu" ];

    hardware.opengl = {
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
        libva

        rocm-opencl-icd
        rocm-opencl-runtime
      ];
    };


    environment = {
      systemPackages = with pkgs; [
        libva-utils
        glxinfo
      ];
    };
  };
}
