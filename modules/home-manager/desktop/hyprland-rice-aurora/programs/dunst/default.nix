{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  config = mkIf (cfg.riceSetup == "hyprland-rice-aurora") {
    home.packages = [ pkgs.dunst ];
    xdg.configFile."dunst/dunstrc".source = ./dunstrc;
  };
}
