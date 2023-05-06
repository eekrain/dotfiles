{ config, pkgs, ... }:
{
  imports = [
    ./waybar
    ./wofi
    ./mpv
    ./bat
    ./btop
    ./cava
    ./dunst
  ];

  home.packages = [ pkgs.mpvpaper ];
}
