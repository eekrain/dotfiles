{ config, pkgs, ... }:
{
  imports = [
    ./waybar
    ./rofi
    ./wofi
    ./mpv
    ./bat
    ./btop
    ./cava
    ./dunst
  ];

  home.packages = [ pkgs.mpvpaper ];
}
