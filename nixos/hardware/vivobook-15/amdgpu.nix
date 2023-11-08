{ config, inputs, pkgs, ... }:
{
  imports = [ inputs.hardware.nixosModules.common-gpu-amd ];

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
    systemPackages = with pkgs; [
      libva
      libva-utils
      glxinfo
    ];
  };
}
