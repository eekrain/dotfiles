{ config, pkgs, ... }:
{
  home.packages = [ pkgs.btop ];
  xdg.configFile."btop/themes".source = ./themes;
  xdg.configFile."btop/themes".recursive = true;
  xdg.configFile."btop/btop.conf".source = ./btop.conf;
}
