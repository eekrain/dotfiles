{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
  initMyWallpaper = pkgs.writeShellScriptBin "initMyWallpaper" ''
    swww-daemon &
    sleep 1
    wall ~/.config/wallpapers/1.jpg #sets lightweigh wallpaper first
    sleep 10
    # then sets my favorite .gif wallpaper
    wall ~/.config/wallpapers/misono-mika-angel-blue-archive-moewalls.gif
  '';
in
{
  imports = [
    ./programs
    ./scripts
    ./theme
  ];

  config = mkIf (cfg.riceSetup == "hyprland-rice-aurora") {
    # For waybar modules to read playing media
    home.packages = [ pkgs.waybar-mpris initMyWallpaper ];

    wayland.windowManager.hyprland = {
      extraConfig = ''
        animations {
          enabled=1
          # bezier=overshot,0.05,0.9,0.1,1.1
          bezier=overshot,0.13,0.99,0.29,1.1
          animation=windows,1,4,overshot,slide
          animation=border,1,10,default
          animation=fade,1,10,default
          animation=workspaces,1,6,overshot,slidevert
        }
      '';

      settings = {
        master = { };
        dwindle = {
          pseudotile = "1"; # enable pseudotiling on dwindle
          force_split = "0";
        };

        general = {
          sensitivity = "1.0"; # for mouse cursor
          gaps_in = "3";
          gaps_out = "5";
          border_size = "3";
          "col.active_border" = "rgba(cba6f7ff) rgba(89b4faff) rgba(94e2d5ff) 10deg";
          "col.inactive_border" = "0xff45475a";
          apply_sens_to_raw = "0"; # whether to apply the sensitivity to raw input (e.g. used by games where you aim using your mouse)
          layout = "dwindle"; # master|dwindle 
        };

        decoration = {
          rounding = "15";
          drop_shadow = "true";
          shadow_range = "100";
          shadow_render_power = "5";
          "col.shadow" = "0x33000000";
          "col.shadow_inactive" = "0x22000000";

          blur = {
            enabled = "true";
            size = "3";
            passes = "1";
            new_optimizations = "true";
            xray = "true";
            ignore_opacity = "false";
          };
        };

        exec-once = [
          "waybar"
          "dunst"
          "initMyWallpaper"

          "touchpadtoggle"
          "~/.config/hypr/scripts/tools/dynamic"
          ''notify-send -a aurora "hello $(whoami)"''

          "gtk-launch brave-browser.desktop"
          "gtk-launch motrix.desktop"
          # Disabling proxy on startup
          "myProxyScript check && myProxyScript toggle"
        ];
      };
    };
  };
}
