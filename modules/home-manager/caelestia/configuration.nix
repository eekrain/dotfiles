{ config, lib, ... }: {
  programs.caelestia.settings = {
    # paths.wallpaperDir = "~/Images";
    appearance = {
      anim = { durations = { scale = 0.7; }; };
      padding = { scale = 0.5; };
      transparency = {
        enabled = true;
        base = 0.6;
        layers = 0.4;
      };
    };
    general = {
      apps = {
        terminal = [ "ghostty" ];
        audio = [ "pavucontrol" ];
      };
    };
    background = { desktopClock = { enabled = true; }; };
    bar = {
      sizes = { innerWidth = 32; };
      status = {
        showAudio = true;
        showMicrophone = true;
      };
      tray = { recolour = false; };
      workspaces = {
        activeLabel = "";
        label = "";
        occupiedLabel = "";
        shown = 5;
      };
    };
    border = { thickness = 1; };
    dashboard = { dragThreshold = 10; };
    launcher = {
      vimKeybinds = true;
      enableDangerousActions = true;
      maxShown = 10;
    };
    notifs = {
      actionOnClick = true;
      defaultExpireTimeout = 3000;
    };
    osd = { hideDelay = 1000; };
    session = {
      vimKeybinds = true;
      commands = {
        logout = [ "loginctl" "terminate-user" "" ];
        shutdown = [ "systemctl" "poweroff" ];
        hibernate = [ "systemctl" "hibernate" ];
        reboot = [ "systemctl" "reboot" ];
      };
    };
  };

  # Enable CLI
  programs.caelestia.cli = {
    enable = true;
  };
}