{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  config = mkIf cfg.easyeffect-audio {
    services.easyeffects = {
      enable = true;
    };

    xdg.configFile."easyeffects/output".source = ./presets;
    xdg.configFile."easyeffects/output".recursive = true;
  };
}
