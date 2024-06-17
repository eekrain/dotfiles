{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.wofi = mkEnableOption "Enable wofi settings";

  config = mkIf cfg.wofi {
    home.packages = with pkgs; [
      wofi
    ];

    xdg.configFile."wofi".source = ./config;
  };
}
