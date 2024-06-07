{ inputs, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  imports = [
    inputs.hyprland.homeManagerModules.default
    ./config.nix
    ./env.nix
  ];

  options.myHmModules.desktop.hyprland.enable = mkEnableOption "Enable installing hyprland with basic and my preferred keybind";

  config = mkIf cfg.enable {
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
