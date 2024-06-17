{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.btop = mkEnableOption "Enable btop settings";

  config = mkIf cfg.btop {
    home.packages = [pkgs.btop];
    xdg.configFile."btop/themes".source = ./themes;
    xdg.configFile."btop/themes".recursive = true;
    xdg.configFile."btop/btop.conf".source = ./btop.conf;
  };
}
