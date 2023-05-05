{ pkgs, ... }:
{
  imports = [
    ./hyprland-conf.nix
    ./autostart.nix
  ];

  home.packages = with pkgs; [
    waybar-mpris
    swww
  ];

  xdg.configFile."hypr/scripts".source = ./scripts;
  xdg.configFile."hypr/scripts".recursive = true;
  xdg.configFile."hypr/wallpapers".source = ./wallpapers;
  xdg.configFile."hypr/wallpapers".recursive = true;
}
