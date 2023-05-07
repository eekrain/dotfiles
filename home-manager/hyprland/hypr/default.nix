{ pkgs, ... }:
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
  myswaylock = pkgs.writeShellScriptBin "myswaylock" ''
    swaylock  \
      --screenshots \
      --clock \
      --indicator \
      --indicator-radius 100 \
      --indicator-thickness 7 \
      --effect-blur 7x5 \
      --effect-vignette 0.5:0.5 \
      --ring-color 3b4252 \
      --key-hl-color f38ba8 \
      --line-color 89dcebff \
      --inside-color 585b7088 \
      --font "Noto Sans" \
      --text-color cdd6f4ff \
      --separator-color 00000000 \
      --grace 2 \
      --fade-in 0.3
  '';
  myswayidle = pkgs.writeShellScriptBin "myswayidle" ''
    swayidle -w  \
      timeout 60 "myswaylock"\
      timeout 600 "systemctl --suspend-hybrid" \
      timeout 1800 "systemctl hibernate"\
      before-sleep 'myswaylock'
  '';
in
{
  imports = [
    ./hypr-variables.nix
    ./hyprland-conf.nix
  ];

  home.packages = with pkgs; [
    waybar-mpris
    swww
    hypr_autostart
    myswaylock
    myswayidle
  ];

  xdg.configFile."hypr/scripts".source = ./scripts;
  xdg.configFile."hypr/scripts".recursive = true;
  xdg.configFile."hypr/wallpapers".source = ./wallpapers;
  xdg.configFile."hypr/wallpapers".recursive = true;
}
