{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  imports = [
    inputs.anyrun.homeManagerModules.default
  ];
  config = mkIf (cfg.riceSetup == "hyprland-rice-illogical-impulse") {
    programs.anyrun = {
      enable = true;
      config = {
        plugins = with inputs.anyrun.packages.${pkgs.system}; [
          applications
          randr
          rink
          shell
          symbols
        ];

        width.fraction = 0.3;
        y.absolute = 15;
        hidePluginInfo = true;
        closeOnClick = true;
      };
    };
  };
}
