{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  config = mkIf cfg.hypridle {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof swaylock || swaylock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "hyprctl dispatch dpms on"; # turning on display before suspend.
          ignore_dbus_inhibit = false;
        };

        listener = [
          {
            timeout = "30"; # 0.5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 60; # 0.5min
            on-timeout = "hyprctl dispatch dpms on && swaylock && sleep 3 && hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
        ];
      };
    };
  };
}
