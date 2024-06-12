{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.desktop;
in
{
  config = mkIf cfg.sddm.enable {
    # Display manager
    services = {
      xserver.enable = true;
      displayManager.defaultSession = cfg.sddm.defaultSession;
      displayManager.sddm.enable = true;
      displayManager.sddm.enableHidpi = true;
      displayManager.sddm.theme = "sugar-candy";
    };

    # Enabling gnome keyring
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.hyprlock.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;


    # limit timeout, cus using sddm while executing shutdown via command 
    # (without exiting hyprland first) took so long idk why
    systemd.extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';

    environment.systemPackages = with pkgs; [
      libsForQt5.qt5.qtgraphicaleffects # for sddm theme
      sddm-sugar-candy
    ];
  };
}
