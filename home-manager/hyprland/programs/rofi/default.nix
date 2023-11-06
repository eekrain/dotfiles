{ config, pkgs, ... }:
{
  home.packages = with pkgs;[
    rofi-wayland-unwrapped
  ];

  xdg.configFile."rofi".source = ./config;
  xdg.configFile."rofi".recursive = true;
}
