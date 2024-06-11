{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.programs;
in
{
  config = mkIf cfg.hyprlock {
    programs.hyprlock = {
      enable = true;

      settings = {
        background = [
          {
            monitor = "";
            path = "$HOME/Pictures/wallpapers/zhyprlock_blurred_bg.png"; # only png supported for now

            # all these options are taken from hyprland, see https://wiki.hyprland.org/Configuring/Variables/#blur for explanations
            blur_size = "0";
            blur_passes = "0"; # 0 disables blurring
            noise = "0.0117";
            contrast = "1.3000"; # Vibrant!!!
            brightness = "0.8000";
            vibrancy = "0.2100";
            vibrancy_darkness = "0.0";
          }
        ];
        input-field = [
          {
            monitor = "";
            size = "250, 50";
            position = "0, 150";
            halign = "center";
            valign = "bottom";

            dots_size = "0.33";
            dots_spacing = "0.15";
            dots_center = "true";
            dots_rounding = "-1";
            outer_color = "rgb(99, 173, 242)";
            inner_color = "rgb(255, 255, 255)";
            font_color = "rgb(37, 65, 178)";
            fade_on_empty = "true";
            fade_timeout = "1000";
            placeholder_text = "<i>Input Password...</i>";
            hide_input = "false";
            rounding = "-1";
            check_color = "rgb(204, 136, 34)";
            fail_color = "rgb(204, 34, 34)";
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            fail_transition = "300";
            capslock_color = "-1";
            numlock_color = "-1";
            bothlock_color = "-1";
            invert_numlock = "false";
            swap_font_color = "false";
          }
        ];
        label = [
          # Current time
          {
            monitor = "";
            text = ''cmd[update:1000] echo "<b><big> $(date +"%H:%M:%S") </big></b>"'';
            color = "rgb(4, 110, 143)";
            font_size = "64";
            font_family = "JetBrains Mono Nerd Font 10";
            shadow_color = "rgb(4, 110, 143)";
            shadow_passes = "3";
            shadow_size = "4";
            position = "0, 16";
            halign = "center";
            valign = "center";
          }
          # Date
          {
            monitor = "";
            text = ''cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"'';
            color = "rgb(46, 41, 78)";
            font_size = "24";
            font_family = "JetBrains Mono Nerd Font 10";
            position = "0, -16";
            halign = "center";
            valign = "center";
          }
          # Date
          {
            monitor = "";
            text = "Hey, $USER 👋";
            color = "rgb(255, 255, 255)";
            font_size = "24";
            font_family = "DM Sans";
            position = "0, 30";
            halign = "center";
            valign = "bottom";
          }
        ];
      };
    };
  };
}
