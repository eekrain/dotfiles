{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.screenshot = mkEnableOption "Enable screenshot script";

  # Script for easier screenshot
  # It will select an area to screenshot, then open it it swappy editing tool
  config = mkIf cfg.screenshot {
    home.packages = with pkgs; [
      grim
      slurp
      swappy
      (pkgs.writeShellScriptBin "screenshot" ''
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -w 0)" - | ${pkgs.swappy}/bin/swappy -f -
      '')
    ];
  };
}
