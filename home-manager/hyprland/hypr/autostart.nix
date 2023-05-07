{ config, lib, pkgs, ... }:

let
  hypr_autostart = pkgs.writeShellScriptBin "hypr_autostart" ''
    config=$HOME/.config/hypr
    scripts=$config/scripts

    # notification daemon
    dunst &

    # waybar
    waybar&
    $scripts/tools/dynamic &

    # wallpaper
    $scripts/wall $config/wallpapers/4.jpg &

    # other
    notify-send -a aurora "hello $(whoami)" &
  '';
in
{
  home.packages = with pkgs; [
    hypr_autostart
  ];
}
