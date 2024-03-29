{ inputs, config, pkgs, ... }:
{
  imports = [
    ./core.nix
    ./fonts.nix
  ];
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.defaultSession = "hyprland";
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.enableHidpi = true;
  services.xserver.displayManager.sddm.theme = "sugar-candy";
  services.xserver.displayManager.sddm.stopScript = ''
    pkill -15 swww-daemon
    if [ -f /run/user/1000/swww.socket ]
    then
      rm /run/user/1000/swww.socket
    fi
    pkill -9 Hyprland
  '';
  # limit timeout, cus using sddm while executing shutdown via command 
  # (without exiting hyprland first) took so long idk why
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland = {
      enable = true;
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };

  services = {
    dbus.packages = [ pkgs.gcr ];
    gvfs.enable = true;
  };

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    light.enable = true;
  };

  security.pam.services.swaylock = { };

  security.doas = {
    enable = true;
    extraConfig = ''
      permit nopass :wheel
    '';
  };
}
