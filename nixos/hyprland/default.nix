{ inputs, config, pkgs, ... }:
{
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  programs.hyprland.enable = true;

  services = {
    dbus.packages = [ pkgs.gcr ];
    gvfs.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs = {
    dconf.enable = true;
    light.enable = true;
  };

  security.pam.services.swaylock = { };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
