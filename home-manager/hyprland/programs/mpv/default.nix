{ config, ... }:
{
  programs = {
    mpv = {
      enable = true;
    };
  };
  xdg.configFile."mpv/mpv.conf".source = ./mpv.conf;
  xdg.configFile."mpv/scripts/file-browser.lua".source = ./scripts/file-browser.lua;
}
