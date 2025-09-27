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
    # Enable BlueZ service with modern configuration
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true; # Ensures Bluetooth is powered on at boot
      settings = {
        General = {
          # Sets the adapter to be easily discoverable and connectable
          FastConnectable = true;
        };
        Policy = {
          # Crucial: Ensures the Bluetooth adapter is enabled and ready upon system start or connection
          AutoEnable = true;
        };
      };
    };

    # Enable Blueman for GUI management
    services.blueman.enable = true;
  };
}
