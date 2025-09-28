{
  config,
  lib,
  pkgs,
  ...
}: {
  services.avizo.enable = true;
  services.clipse = {
    enable = true;
    systemdTarget = "xdg-desktop-portal-hyprland.service";
  };
  programs.quickshell = {
    enable = true;
    systemd.enable = true;
    systemd.target = "xdg-desktop-portal-hyprland.service";
  };
}
