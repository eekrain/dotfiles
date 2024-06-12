{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  imports = [
    ./programs
    ./theme
    ./config
  ];

  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd = {
        enable = true;
        variables = [ "--all" ];
      };
      xwayland.enable = true;
    };
  };
}
