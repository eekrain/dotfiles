{ config, pkgs, ... }:
{
  home.packages = [ pkgs.cava ];
  xdg.configFile."cava/config".source = ./config;
}
