{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.hardware;
in
{
  options.myModules.hardware = {
    powerManagement = mkEnableOption "Enable custom power management settings";
  };

  config = mkIf cfg.powerManagement {
    services.auto-cpufreq.enable = true;

    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 60;
      };
    };
  };
}
