{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop;
in
{
  imports = [
    ./hyprland-basic
    ./hyprland-rice-aurora
    ./hyprland-rice-illogical-impulse
  ];

  options.myHmModules.desktop.hyprland = {
    riceSetup = mkOption {
      description = "Desktop rice to use";
      type = types.enum [
        "hyprland-rice-aurora"
        "hyprland-rice-illogical-impulse"
      ];
      default = "hyprland-rice-aurora";
    };
  };
}
