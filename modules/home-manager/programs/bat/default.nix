{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.bat = mkEnableOption "Enable bat settings";

  config = mkIf cfg.bat {
    home.packages = [pkgs.bat];
    xdg.configFile."bat/themes".source = ./themes;
    xdg.configFile."bat/themes".recursive = true;
    xdg.configFile."bat/bat.config".source = ./bat.config;
  };
}
