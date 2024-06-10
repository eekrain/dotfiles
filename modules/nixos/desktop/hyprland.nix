{ inputs, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.desktop.hyprland;
  touchpadtoggle = pkgs.writeShellScriptBin "touchpadtoggle" ''
    if [ -z "$XDG_RUNTIME_DIR" ]; then
      export XDG_RUNTIME_DIR=/run/user/$(id -u)
    fi
    export STATUS_FILE="$XDG_RUNTIME_DIR/touchpad.status"

    # get your touchpad id by running hyprctl devices
    export HYPRLAND_DEVICE="asue120b:00-04f3:31c0-touchpad"

    enable_touchpad() {
      printf "true" > "$STATUS_FILE"
      notify-send -u normal "Enabling Touchpad"
      hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" true
    }

    disable_touchpad() {
      printf "false" > "$STATUS_FILE"
      notify-send -u normal "Disabling Touchpad"
      hyprctl keyword "device[$HYPRLAND_DEVICE]:enabled" false
    }

    last_stat=$(cat "$STATUS_FILE")
    if [ $last_stat = "true" ]
    then
      disable_touchpad
    elif [ $last_stat = "false" ]
    then
      enable_touchpad
    else
      disable_touchpad
    fi
  '';
in
{
  options.myModules.desktop.hyprland.enable = mkEnableOption "Enable basic hyprland installation";

  config = mkIf cfg.enable {
    hardware.i2c.enable = true;

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      xwayland.enable = true;
      systemd.setPath.enable = true;
    };

    programs = {
      dconf.enable = true;
      light.enable = true;
    };

    security.polkit.enable = true;

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

      # other pkgs
      python3
      eza
      fzf
      jq
      gnome.nautilus
    ];
  };
}
