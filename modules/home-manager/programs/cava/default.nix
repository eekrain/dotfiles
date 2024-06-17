{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.cava = mkEnableOption "Enable cava settings";

  config = mkIf cfg.cava {
    home.packages = [pkgs.cava];
    xdg.configFile."cava/config".source = ./config;
  };
}
