{ config, pkgs, ... }:
{
  home.packages = [ pkgs.bat ];
  xdg.configFile."bat/themes".source = ./themes;
  xdg.configFile."themes".recursive = true;
  xdg.configFile."bat/bat.config".source = ./bat.config;
}
