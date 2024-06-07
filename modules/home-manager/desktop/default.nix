{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop;
in
{
  imports = [
    ./hyprland-basic
    ./hyprland-rice-aurora
  ];

  options.myHmModules.desktop.hyprland = {
    riceSetup = mkOption {
      description = "Desktop rice to use";
      type = types.enum [ "hyprland-rice-aurora" ];
      default = "hyprland-rice-aurora";
    };
  };
}
