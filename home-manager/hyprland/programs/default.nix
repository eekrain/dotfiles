{ config, pkgs, ... }:
{
  imports = [
    ./waybar
    ./rofi
    ./mpv
    ./bat
    ./btop
    ./cava
    ./dunst
  ];

  home.packages = [ pkgs.mpvpaper ];
}
