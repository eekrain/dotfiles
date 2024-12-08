{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myHmModules.programs;
in {
  options.myHmModules.programs.hypridle = mkEnableOption "Enable hypridle settings";

  config = mkIf cfg.hypridle {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
          before_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
          ignore_dbus_inhibit = true;
        };

        listener = [
          {
            timeout = 900; # 1min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 960; # 1.5min
            on-timeout = "loginctl lock-session"; # lock session with hyprlock
          }
          {
            timeout = 1200; # 5min
            on-timeout = "systemctl suspend"; # suspend system
          }
        ];
      };
    };
  };
}
