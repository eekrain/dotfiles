{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.cli;
in
{
  options.cli.kitty = mkEnableOption "Enable kitty settings";
  config = mkIf cfg.kitty {
    programs = {
      kitty = {
        enable = true;
        theme = "Catppuccin-Mocha";
        font.name = "CaskaydiaCove Nerd Font Mono";
        font.size = 15;
        settings = {
          italic_font = "auto";
          bold_italic_font = "auto";
          mouse_hide_wait = 2;
          cursor_shape = "block";
          url_color = "#0087bd";
          url_style = "dotted";
          #Close the terminal =  without confirmation;
          confirm_os_window_close = 0;
          background_opacity = "0.95";
        };
      };
    };
  };
}
