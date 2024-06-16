{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.myModules.desktop.hyprland;
  touchpadtoggle = pkgs.writeShellScriptBin "touchpadtoggle" ''
    if [ -z "$XDG_RUNTIME_DIR" ]; then
        export XDG_RUNTIME_DIR=/run/user/$(id -u)
    fi
    export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

    # get your touchpad id by running hyprctl devices
    export HYPRLAND_DEVICE="asue120b:00-04f3:31c0-touchpad"

    enable_touchpad() {
        printf "1" >"$STATUS_FILE"
        notify-send -u normal "Touchpad enabled" -i ${pkgs.my-icons}/share/icons/touchpad_enabled.svg
        hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" true
    }

    disable_touchpad() {
        printf "0" >"$STATUS_FILE"
        notify-send -u normal "Touchpad disabled" -i ${pkgs.my-icons}/share/icons/touchpad_disabled.svg
        hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" false
    }

    last_stat=$(cat "$STATUS_FILE")
    if [[ $last_stat == "0" ]]; then
        enable_touchpad
    else
        disable_touchpad
    fi
  '';
in {
  options.myModules.desktop.hyprland.enable = mkEnableOption "Enable basic hyprland installation";

  config = mkIf cfg.enable {
    hardware.i2c.enable = true;

    # Enable Location.
    # Used for night light mode
    services.geoclue2.enable = true;
    # Enabling upower service
    # For gnome and ags stuff
    services.upower.enable = true;

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
      systemd.setPath.enable = true;
    };
    programs.dconf.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    environment.systemPackages = with pkgs; [
      grim # screenshot functionality
      slurp # screenshot functionality
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      egl-wayland
      #other pkgs
      xdg-utils # for opening default programs when clicking links
      swww # wallpaper daemon
      gtk3 # needed for gtk-launch command
      libnotify # for sending notification
      touchpadtoggle #script for touchpad toggler
      brightnessctl
    ];

    # Testing portal stuff
    xdg.portal = {
      enable = true;
      config = {
        common = {
          default = [
            "xdph"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.portal.FileChooser" = ["xdg-desktop-portal-gtk"];
        };
      };
      extraPortals = with pkgs; [xdg-desktop-portal-gtk];
    };

    # Polkit stuff

    security.polkit = {
      enable = true;
      debug = true;
      extraConfig = ''
        /* Log authorization checks. */
        polkit.addRule(function(action, subject) {
          polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid);
        });
      '';
    };
    programs.gnupg.agent.enable = true;
  };
}
