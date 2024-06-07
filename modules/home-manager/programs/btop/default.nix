{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  config = mkIf cfg.btop {
    home.packages = [ pkgs.btop ];
    xdg.configFile."btop/themes".source = ./themes;
    xdg.configFile."btop/themes".recursive = true;
    xdg.configFile."btop/btop.conf".source = ./btop.conf;
  };
}
