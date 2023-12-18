{ config, lib, pkgs, osConfig, ... }:

{
  imports = [
    ./theme/catppuccin-dark
    ./hypr
    ./programs
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    xwayland = {
      enable = true;
    };
  };
}
