{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.cli;
in {
  options.myHmModules.cli.kitty = mkEnableOption "Enable kitty settings";
  config = mkIf cfg.kitty {
    home.packages = with pkgs; [
      kitty
    ];
  };
}
