{ config, lib, pkgs, ... }:

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
      hidpi = true;
    };
  };
}
