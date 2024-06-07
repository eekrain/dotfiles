{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.desktop;
in
{
  imports = [
    ./hyprland-basic.nix
    ./hyprland-rice-aurora.nix
  ];

  options.myModules.desktop = {
    hyprland.riceSetup = mkOption {
      description = "Desktop rice to use";
      type = types.enum [ "hyprland-rice-aurora" ];
      default = "hyprland-rice-aurora";
    };

    sddm = {
      enable = mkEnableOption "Enable sddm display manager";
      defaultSession = mkOption {
        description = "Graphical session to pre-select in the session chooser";
        type = types.str;
        default = "hyprland";
      };
    };
  };
}
