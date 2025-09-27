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
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs";
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "QT_QUICK_CONTROLS_STYLE=Basic"
        "QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000"
      ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}