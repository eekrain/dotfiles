{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
  system = "x86_64-linux";
in {
  options.myHmModules.programs.browser = mkEnableOption "Enable browser settings";

  config = mkIf cfg.browser {
    home.packages = [
      inputs.zen-browser.packages."${system}".specific
      pkgs.brave
    ];
  };
}
