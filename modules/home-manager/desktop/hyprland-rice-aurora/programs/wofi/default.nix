{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  config = mkIf (cfg.riceSetup == "hyprland-rice-aurora") {
    home.packages = with pkgs;[
      wofi
    ];

    xdg.configFile."wofi".source = ./config;
  };
}
