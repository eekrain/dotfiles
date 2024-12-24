{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.desktop;
in {
  imports = [
    inputs.hyprland.homeManagerModules.default
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
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
