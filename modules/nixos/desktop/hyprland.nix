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
  options.myModules.desktop.hyprland = {
    enable = mkEnableOption "Enable basic hyprland installation";

    brightnessController = mkOption {
      description = "GPU driver to use";
      type = types.enum ["light" "brightnessctl" "ddcutil"];
      default = "light";
    };
  };

  config = mkIf cfg.enable {
    # Brightness controller settings
    hardware.i2c.enable = true;
    programs.light.enable =
      if (cfg.brightnessController == "light")
      then true
      else false;

    environment.systemPackages = with pkgs;
      [
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
        hyprpolkitagent
      ]
      ++ optionals (cfg.brightnessController == "ddcutil") [ddcutil] #install ddcutil if ddcutil selected as brightnessController
      ++ optionals (cfg.brightnessController == "brightnessctl") [brightnessctl]; #install brightnessctl if brightnessctl selected as brightnessController
    # Enable Location.
    # Used for night light mode
    services.geoclue2.enable = true;
    # Enabling upower service
    # For gnome and ags stuff
    services.upower.enable = true;
    # Enable gnome keyring by default
    services.gnome.gnome-keyring.enable = true;

    programs.hyprland = {
      enable = true;
      # set the flake package
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      # make sure to also set the portal package, so that they are in sync
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

      withUWSM = true;
    };
    programs.dconf.enable = true;
    # # FS tools for compatibility with desktop
    # services.envfs.enable = true;
    services.gvfs.enable = true;

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Testing portal stuff
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      config = {
        common.default = ["gtk"];
        hyprland.default = ["gtk" "hyprland"];
      };

      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };

    # Polkit stuff
    security.polkit.enable = true;
    programs.gnupg.agent.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
  };
}
