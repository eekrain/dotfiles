{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.hardware;
in {
  imports = [inputs.auto-cpufreq.nixosModules.default];
  options.myModules.hardware.powerManagement = mkEnableOption "Enable custom power management settings";

  config = mkIf cfg.powerManagement {
    environment.systemPackages = [pkgs.dmidecode];
    programs.auto-cpufreq.enable = true;

    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 60;
      };
    };
  };
}
