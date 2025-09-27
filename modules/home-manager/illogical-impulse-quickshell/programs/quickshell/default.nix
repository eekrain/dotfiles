{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    quickshell
    swww
    clipse
    wl-clip-persist
    grimblast
    satty
  ];

  # Quickshell autostart
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell shell";
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}