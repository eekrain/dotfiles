{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.hardware;
in
{
  config = mkIf cfg.bluetooth {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    hardware.bluetooth.powerOnBoot = false;
  };
}
