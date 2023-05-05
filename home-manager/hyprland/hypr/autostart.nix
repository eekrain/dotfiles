{ config, lib, pkgs, ... }:

let
  hypr_autostart = pkgs.writeShellScriptBin "hypr_autostart" ''
    config=$HOME/.config/hypr
    scripts=$config/scripts

    # waybar
    waybar&

    # wallpaper
    $scripts/wall $config/wallpapers/4.jpg &
  '';
in
{
  home.packages = with pkgs; [
    hypr_autostart
  ];
}
