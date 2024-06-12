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

    programs.zsh = {
      # Creating required dir and files for dynamic bar to works
      initExtra = ''
        hypr_store=$HOME/.config/hypr/store
      
        if [ ! -f $hypr_store/dynamic_out.txt ]
        then
          mkdir -p $hypr_store
          touch $hypr_store/dynamic_out.txt $hypr_store/latest_notif $hypr_store/prev.txt
        fi
      '';
    };
  };
}
