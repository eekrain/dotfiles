{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  config = mkIf cfg.swaylock {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;

      settings = {
        screenshots = true;
        clock = true;
        indicator = true;
        indicator-radius = "100";
        indicator-thickness = "7";
        effect-blur = "7x5";
        effect-vignette = "0.5:0.5";
        ring-color = "3b4252";
        key-hl-color = "f38ba8";
        line-color = "89dcebff";
        inside-color = "585b7088";
        font = "Noto Sans";
        text-color = "cdd6f4ff";
        separator-color = "00000000";
        grace = "2";
        fade-in = "0.3";
      };
    };
  };
}
