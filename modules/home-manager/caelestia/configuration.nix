{ config, lib, ... }: {
  programs.caelestia.settings = {
    # Appearance settings
    appearance = {
      anim = {
        durations = {
          scale = 0.7;
        };
      };
      padding = {
        scale = 0.5;
      };
      transparency = {
        enabled = true;
        base = 0.6;
        layers = 0.4;
      };
    };

    # General settings
    general = {
      apps = {
        terminal = [ "ghostty" ];
        audio = [ "pavucontrol" ];
      };
    };

    # Background settings
    background = {
      desktopClock = {
        enabled = true;
      };
    };

    # Bar configuration
    bar = {
      sizes = {
        innerWidth = 32;
      };
      status = {
        showAudio = true;
        showMicrophone = true;
      };
      tray = {
        recolour = false;
      };
      workspaces = {
        activeLabel = "";
        label = "";
        occupiedLabel = "";
        shown = 5;
      };
    };

    # Border settings
    border = {
      thickness = 1;
    };

    # Dashboard settings
    dashboard = {
      dragThreshold = 10;
    };

    # Launcher settings
    launcher = {
      vimKeybinds = true;
      enableDangerousActions = true;
      maxShown = 10;
    };

    # Notification settings
    notifs = {
      actionOnClick = true;
      defaultExpireTimeout = 3000;
    };

    # OSD settings
    osd = {
      hideDelay = 1000;
    };

    # Session settings
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