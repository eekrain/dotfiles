{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.hardware;
in {
  options.myModules.hardware.bluetooth = mkEnableOption "Enable custom bluetooth settings";

  config = mkIf cfg.bluetooth {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    hardware.bluetooth.powerOnBoot = false;
  };
}
