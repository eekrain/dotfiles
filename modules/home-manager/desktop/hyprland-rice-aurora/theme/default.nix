{ inputs, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myHmModules.desktop.hyprland;
in
{
  imports = [ inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger ];

  config = mkIf (cfg.riceSetup == "hyprland-rice-aurora") {
    programs.hyprcursor-phinger.enable = true;
    home.sessionVariables = {
      HYPRCURSOR_THEME = "phinger-cursors-dark";
      HYPRCURSOR_SIZE = "24";
    };
    home.pointerCursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-dark";
      size = 10;
      gtk.enable = true;
    };
    gtk.cursorTheme = {
      name = "phinger-cursors-dark";
      size = 24;
    };

    gtk = {
      enable = true;

      theme = {
        package = pkgs.orchis-theme.override {
          tweaks = [ "solid" "nord" ];
        };
        name = "Orchis-Dark-Nord";
      };

      iconTheme = {
        package = pkgs.morewaita-icon-theme;
        name = "MoreWaita";
      };

      font = {
        name = "DM Sans";
        size = 12;
      };

      gtk3.extraConfig = {
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
      };

      gtk2.extraConfig = ''
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba="rgb"
      '';
    };
  };
}
