{ config, pkgs, ... }:
{
  home.packages = with pkgs;[
    wofi
  ];

  xdg.configFile."wofi".source = ./config;
}
