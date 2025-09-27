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
  services.hyprshell = {
    enable = true;
    settings = {
      version = 2;
      windows = {
        switch = {
          switch_workspaces = false;
          modifier = "alt";
        };
      };
    };
  };
  programs.quickshell = {
    enable = true;
    systemd.enable = true;
    systemd.target = "xdg-desktop-portal-hyprland.service";
  };
}
