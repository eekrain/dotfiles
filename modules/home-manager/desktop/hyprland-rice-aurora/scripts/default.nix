{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  config = mkIf (cfg.riceSetup == "hyprland-rice-aurora") {
    xdg.configFile."hypr/scripts".source = ./files;
    xdg.configFile."hypr/scripts".recursive = true;
  };
}
