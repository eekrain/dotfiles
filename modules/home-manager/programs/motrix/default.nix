{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.motrix = mkEnableOption "Enable motrix settings";

  config = mkIf cfg.motrix {
    home.packages = [pkgs.motrix];

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
