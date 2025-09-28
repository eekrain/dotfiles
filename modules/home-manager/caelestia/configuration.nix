{
  config,
  lib,
  ...
}: {
  programs.caelestia.settings = {
    appearance = {
      anim.durations.scale = 0.7;
      transparency = {
        base = 0.6;
        enabled = false;
        layers = 0.4;
      };
      padding.scale = 1;
      rounding.scale = 1;
      spacing.scale = 1;
    };

    background.desktopClock.enabled = true;

    bar = {
      sizes.innerWidth = 32;
      status = {
        showAudio = true;
        showMicrophone = true;
      };
      tray.recolour = false;
      workspaces = {
        activeLabel = "";
        label = "";
        occupiedLabel = "";
        shown = 5;
      };
    };

    border.thickness = 1;

    dashboard.dragThreshold = 10;

    general.apps = {
      audio = ["pavucontrol"];
      terminal = ["ghostty"];
    };

    launcher = {
      enableDangerousActions = true;
      maxShown = 10;
      vimKeybinds = true;
    };

    notifs = {
      actionOnClick = true;
      defaultExpireTimeout = 3000;
    };

    osd.hideDelay = 1000;

    session = {
      commands = {
        hibernate = ["systemctl" "hibernate"];
        logout = ["loginctl" "terminate-user" ""];
        reboot = ["systemctl" "reboot"];
        shutdown = ["systemctl" "poweroff"];
      };
      vimKeybinds = true;
    };
  };

  # Enable CLI
  programs.caelestia.cli = {
    enable = true;
  };
}
