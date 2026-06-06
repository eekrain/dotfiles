{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.desktop;
in {
  imports = [
    inputs.qylock.nixosModules.default
  ];

  options.myModules.desktop = {
    sddm = {
      enable = mkEnableOption "Enable sddm display manager";
      defaultSession = mkOption {
        description = "Graphical session to pre-select in the session chooser";
        type = types.str;
        default = "hyprland";
      };
    };
  };

  config = mkIf cfg.sddm.enable {
    # Display manager
    services = {
      xserver.enable = true;
      displayManager.defaultSession = cfg.sddm.defaultSession;
      displayManager.sddm.enable = true;
      displayManager.sddm.enableHidpi = true;
    };

    programs.qylock = {
      enable = true;
      theme = "pixel-cyberpunk";
      sddm.enable = true;
      quickshell.enable = false;
    };

    # Enabling gnome keyring
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.hyprlock.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;

    # limit timeout, cus using sddm while executing shutdown via command
    # (without exiting hyprland first) took so long idk why
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";

  };
}
