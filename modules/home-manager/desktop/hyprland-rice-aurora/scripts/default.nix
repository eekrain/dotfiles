{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
  wall = pkgs.writeShellScriptBin "wall" ''
    swww img $1 --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
  '';
in
{
  config = mkIf (cfg.riceSetup == "hyprland-rice-aurora") {
    home.packages = [ wall ];
    xdg.configFile."hypr/scripts".source = ./files;
    xdg.configFile."hypr/scripts".recursive = true;
  };
}
