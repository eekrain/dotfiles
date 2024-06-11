{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  config = mkIf cfg.wofi {
    home.packages = with pkgs;[
      wofi
    ];

    xdg.configFile."wofi".source = ./config;
  };
}
