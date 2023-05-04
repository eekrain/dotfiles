{ pkgs, config, ... }:
{
  # home.packages = with pkgs; [ wezterm ]; //already added on core profile

  xdg.configFile."wezterm/wezterm.lua".source = ./wezterm.lua;
}
