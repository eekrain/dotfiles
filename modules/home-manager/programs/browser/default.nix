{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.browser = mkEnableOption "Enable browser settings";

  config = mkIf cfg.browser {
    home.packages = [
      pkgs.zen-browser
    ];
  };
}
