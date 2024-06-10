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
        variables = [
          "DISPLAY"
          "HYPRLAND_INSTANCE_SIGNATURE"
          "WAYLAND_DISPLAY"
          "XDG_CURRENT_DESKTOP"
          "PATH"
          "XDG_DATA_DIRS"
        ];
      };
      xwayland.enable = true;
    };
  };
}
