{ config, ... }:
{
  programs = {
    mpv = {
      enable = true;
    };
  };
  xdg.configFile."mpv/input.conf".source = ./input.conf;
  xdg.configFile."mpv/mpv.conf".source = ./mpv.conf;
  xdg.configFile."mpv/scripts/file-browser.lua".source = ./scripts/file-browser.lua;
  xdg.configFile."mpv/shaders".source = ./shaders;
  xdg.configFile."mpv/shaders".recursive = true;
}
