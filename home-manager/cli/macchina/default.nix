{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ macchina ];

  xdg.configFile."macchina".source = ./config;
}
