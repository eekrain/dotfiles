{ ... }: {
  services.clipse = {
    enable = true;
    systemdTarget = "xdg-desktop-portal-hyprland.service";
  };
}