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
      Documentation = [ "https://quickshell.org" ];
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" "graphical-session.target" ];
      Wants = [ "hyprland-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.quickshell}/bin/qs";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      Restart = "always";
      RestartSec = 2;
      TimeoutStartSec = 30;
      TimeoutStopSec = 10;
      WorkingDirectory = "%h";
      Environment = [
        "QT_QUICK_CONTROLS_STYLE=Basic"
        "QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000"
        "QT_QPA_PLATFORM=wayland"
        "PATH=${config.home.profileDirectory}/bin:/run/wrappers/bin:${config.home.homeDirectory}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
        "XDG_DATA_DIRS=${config.home.profileDirectory}/share:${config.home.homeDirectory}/.nix-profile/share:/etc/profiles/per-user/${config.home.username}/share:/nix/var/nix/profiles/default/share:/run/current-system/sw/share"
      ];
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };

  # Create hyprland session target if it doesn't exist
  systemd.user.targets.hyprland-session = {
    Unit = {
      Description = "Hyprland compositor session";
      Documentation = [ "man:systemd.special(7)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };
}