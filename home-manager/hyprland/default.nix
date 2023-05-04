{ config, lib, pkgs, ... }:

{
  imports = [
    ./theme/catppuccin-dark
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    recommendedEnvironment = true;
    nvidiaPatches = false;
  };
}
