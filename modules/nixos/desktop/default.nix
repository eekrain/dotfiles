{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModule.desktop;
in
{
  imports = [
    ./hyprland-basic.nix
    ./hyprland-rice-aurora.nix
  ];

  options.myModule.desktop = {
    hyprland.riceSetup = mkOption {
      description = "Desktop rice to use";
      type = types.enum [ "hyprland-rice-aurora" ];
      default = "hyprland-rice-aurora";
    };
  };
}
