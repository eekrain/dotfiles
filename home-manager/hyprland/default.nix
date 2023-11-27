{ config, lib, pkgs, osConfig, ... }:

{
  imports = [
    ./theme/catppuccin-dark
    ./hypr
    ./programs
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = false;
    recommendedEnvironment = true;
    xwayland = {
      enable = true;
    };
  };
}
