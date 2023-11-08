{ lib, pkgs, config, inputs, ... }:
with lib;
let
  cfg = config.hardware.amdgpu;
in
{
  imports = [ inputs.hardware.nixosModules.common-gpu-amd ];

  options.hardware.amdgpu = {
    enable = mkEnableOption "Enable AMD GPU";
  };

  config = mkIf cfg.enable {
    hardware.amdgpu = {
      loadInInitrd = true;
      opencl = true;
    };

    hardware.opengl = {
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    environment = {
      sessionVariables = rec {
        LIBVA_DRIVER_NAME = "radeonsi";
        VDPAU_DRIVER = "radeonsi";
        # WLR_NO_HARDWARE_CURSORS = "1"; # if no cursor,uncomment this line  
      };

      systemPackages = with pkgs; [
        libva
        libva-utils
        glxinfo
      ];
    };
  };
}
