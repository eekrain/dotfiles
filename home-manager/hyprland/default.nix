{ config, lib, pkgs, osConfig, ... }:

{
  imports = [
    ./theme/catppuccin-dark
    ./hypr
    ./programs
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    recommendedEnvironment = true;
    xwayland = {
      enable = true;
    };
    enableNvidiaPatches = if osConfig.hardware.nvidia.enable then true else false;
  };
}
