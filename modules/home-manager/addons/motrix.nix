{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.myHmModules.addons;
in
{
  config = mkIf cfg.enable {
    home.packages = [ pkgs.motrix ];

    xdg.desktopEntries.motrix = {
      name = "Motrix";
      genericName = "Download Manager";
      exec = "motrix --no-sandbox --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
      type = "Application";
      terminal = false;
      icon = "motrix";
      comment = ''A full-featured download manager'';
      settings = {
        StartupWMClass = "Motrix";
        Categories = "Network";
        MimeType = "application/x-bittorrent;x-scheme-handler/magnet;application/x-bittorrent;x-scheme-handler/mo;x-scheme-handler/motrix;x-scheme-handler/magnet;x-scheme-handler/thunder;";
      };
    };
  };
}
