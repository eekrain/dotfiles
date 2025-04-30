{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.easyeffect-audio = mkEnableOption "Enable easyeffect-audio settings";

  config = mkIf cfg.easyeffect-audio {
    services.easyeffects = {
      enable = true;
      package = pkgs.pkgs2411.easyeffects;
    };

    xdg.configFile."easyeffects/output".source = ./presets;
    xdg.configFile."easyeffects/output".recursive = true;
  };
}
